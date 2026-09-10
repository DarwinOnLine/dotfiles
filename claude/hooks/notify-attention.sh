#!/usr/bin/env bash
# Claude Code attention notifier.
#
# Usage (from settings.json hooks):
#   notify-attention.sh notify  -> Notification hook: sound + desktop toast + tab marker
#   notify-attention.sh clear   -> UserPromptSubmit hook: remove the tab marker
#   notify-attention.sh focus   -> invoked when the toast's action is clicked
#
# Identifying the conversation: Claude Code writes the conversation topic into
# the terminal tab title, and Konsole exports its own DBus coordinates into the
# environment (KONSOLE_DBUS_SERVICE / _WINDOW / _SESSION), which the hook
# inherits. So the toast is titled with the actual conversation topic, and its
# action button switches Konsole to the right tab.
#
# Cross-platform: Linux (KDE/GNOME), WSL2, macOS. Degrades to the terminal bell
# when no notification backend is available. Never fails the hook.

set -uo pipefail

ACTION="${1:-notify}"
PAYLOAD=""
[ -t 0 ] || PAYLOAD="$(cat 2>/dev/null || true)"

json() { printf '%s' "$PAYLOAD" | jq -r "$1 // empty" 2>/dev/null; }

MESSAGE="$(json '.message')"
[ -n "$MESSAGE" ] || MESSAGE="Claude Code attend une réponse"
[ "${#MESSAGE}" -le 200 ] || MESSAGE="${MESSAGE:0:197}..."

CWD="$(json '.cwd')"
[ -n "$CWD" ] || CWD="${CLAUDE_PROJECT_DIR:-$PWD}"
PROJECT="$(basename "$CWD")"

SESSION="$(json '.session_id')"
[ -n "$SESSION" ] || SESSION="${CLAUDE_SESSION_ID:-unknown}"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/claude-notify"
STATE_FILE="$STATE_DIR/$SESSION"

MARKER='🔔 '
LOG="$STATE_DIR/debug.log"

# Enable with CLAUDE_NOTIFY_DEBUG=1 to trace the toast-action path.
dbg() {
  [ -n "${CLAUDE_NOTIFY_DEBUG:-}" ] || return 0
  mkdir -p "$STATE_DIR" 2>/dev/null || return 0
  printf '%s [%s] %s\n' "$(date +%H:%M:%S)" "${ACTION}" "$*" >>"$LOG" 2>/dev/null || true
}

platform() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)
      if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
        echo wsl
      else
        echo linux
      fi
      ;;
    *) echo other ;;
  esac
}
PLATFORM="$(platform)"

# --- Konsole DBus -------------------------------------------------------------
QDBUS=""
for c in qdbus-qt6 qdbus6 qdbus; do
  command -v "$c" >/dev/null 2>&1 && { QDBUS="$c"; break; }
done

konsole_ok() {
  [ -n "$QDBUS" ] && [ -n "${KONSOLE_DBUS_SERVICE:-}" ] \
    && [ -n "${KONSOLE_DBUS_SESSION:-}" ] && [ -n "${KONSOLE_DBUS_WINDOW:-}" ]
}

# Session.title(1) is the tab title, which is where Claude Code puts the topic.
konsole_tab_title() {
  konsole_ok || return 1
  "$QDBUS" "$KONSOLE_DBUS_SERVICE" "$KONSOLE_DBUS_SESSION" \
    org.kde.konsole.Session.title 1 2>/dev/null
}

# Switch Konsole to this conversation's tab, then ask the window to come up.
# setCurrentSession is an app-level call, so it works under Wayland; the
# QWidget.raise() is best-effort (KWin may refuse focus stealing).
konsole_focus() {
  if ! konsole_ok; then
    dbg "konsole_ok=false qdbus='$QDBUS' svc='${KONSOLE_DBUS_SERVICE:-}' ses='${KONSOLE_DBUS_SESSION:-}' win='${KONSOLE_DBUS_WINDOW:-}'"
    return 1
  fi
  local sid="${KONSOLE_DBUS_SESSION##*/}" wnum="${KONSOLE_DBUS_WINDOW##*/}" out rc
  out="$("$QDBUS" "$KONSOLE_DBUS_SERVICE" "$KONSOLE_DBUS_WINDOW" \
    org.kde.konsole.Window.setCurrentSession "$sid" 2>&1)"; rc=$?
  dbg "setCurrentSession($sid) rc=$rc out='$out'"
  out="$("$QDBUS" "$KONSOLE_DBUS_SERVICE" "/konsole/MainWindow_$wnum" \
    org.qtproject.Qt.QWidget.raise 2>&1)"; rc=$?
  dbg "MainWindow_$wnum.raise rc=$rc out='$out'"
}

# --- terminal title fallback --------------------------------------------------
# Hook stdout is captured by Claude Code, so escape sequences must go straight
# to the controlling terminal. OSC 0 = window title, OSC 30 = Konsole tab title.
tty_write() {
  ( exec 2>/dev/null; printf '%b' "$1" >/dev/tty ) || true
}

# Deliberately NOT org.kde.konsole.Session.setTitle: that pins the tab title
# and disables Konsole's dynamic title format for the rest of the session.
set_title() {
  tty_write "\033]0;$1\007\033]30;$1\007"
}

# --- sound --------------------------------------------------------------------
play_sound() {
  case "$PLATFORM" in
    macos)
      afplay /System/Library/Sounds/Ping.aiff >/dev/null 2>&1 && return 0
      ;;
    wsl)
      powershell.exe -NoProfile -Command '[console]::beep(880,150)' >/dev/null 2>&1 && return 0
      ;;
    *)
      local snd=/usr/share/sounds/freedesktop/stereo/message.oga
      [ -f "$snd" ] || snd=/usr/share/sounds/freedesktop/stereo/bell.oga
      if [ -f "$snd" ]; then
        command -v paplay  >/dev/null 2>&1 && paplay  "$snd" >/dev/null 2>&1 && return 0
        command -v pw-play >/dev/null 2>&1 && pw-play "$snd" >/dev/null 2>&1 && return 0
      fi
      command -v canberra-gtk-play >/dev/null 2>&1 \
        && canberra-gtk-play -i message >/dev/null 2>&1 && return 0
      ;;
  esac
  tty_write '\a'
}

# --- desktop notification -----------------------------------------------------
notify_desktop() {
  local title="$1" body="$2"
  case "$PLATFORM" in
    macos)
      if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier -title "$title" -message "$body" -sound Ping >/dev/null 2>&1 && return 0
      fi
      osascript -e "display notification \"${body//\"/\\\"}\" with title \"${title//\"/\\\"}\"" \
        >/dev/null 2>&1 && return 0
      ;;
    wsl)
      command -v notify-send.exe >/dev/null 2>&1 \
        && notify-send.exe "$title" "$body" >/dev/null 2>&1 && return 0
      command -v wsl-notify-send.exe >/dev/null 2>&1 \
        && wsl-notify-send.exe --category "$title" "$body" >/dev/null 2>&1 && return 0
      powershell.exe -NoProfile -Command "
        Add-Type -AssemblyName System.Windows.Forms
        \$n = New-Object System.Windows.Forms.NotifyIcon
        \$n.Icon = [System.Drawing.SystemIcons]::Information
        \$n.BalloonTipTitle = '${title//\'/\'\'}'
        \$n.BalloonTipText  = '${body//\'/\'\'}'
        \$n.Visible = \$true
        \$n.ShowBalloonTip(10000)
        Start-Sleep -Seconds 6
        \$n.Dispose()" >/dev/null 2>&1 &
      return 0
      ;;
    *)
      command -v notify-send >/dev/null 2>&1 || { tty_write '\a'; return 0; }
      # An action implies --wait, which blocks until the toast is closed, so the
      # watcher is detached and capped: the hook itself must return immediately.
      if konsole_ok; then
        setsid --fork env \
          CLAUDE_NOTIFY_DEBUG="${CLAUDE_NOTIFY_DEBUG:-}" \
          KONSOLE_DBUS_SERVICE="$KONSOLE_DBUS_SERVICE" \
          KONSOLE_DBUS_SESSION="$KONSOLE_DBUS_SESSION" \
          KONSOLE_DBUS_WINDOW="$KONSOLE_DBUS_WINDOW" \
          bash -c '
            picked=$(timeout 600 notify-send -a "Claude Code" -i utilities-terminal \
              -u normal -t 0 \
              -h string:desktop-entry:org.kde.konsole \
              -A "focus=Aller à la conversation" \
              "$1" "$2" 2>/dev/null)
            [ -n "${CLAUDE_NOTIFY_DEBUG:-}" ] && \
              printf "%s [watcher] picked=%s\n" "$(date +%H:%M:%S)" "${picked:-<none>}" \
                >>"$5/debug.log" 2>/dev/null
            [ "$picked" = "focus" ] && exec "$3" focus </dev/null
          ' _ "$title" "$body" "$0" "$SESSION" "$STATE_DIR" </dev/null >/dev/null 2>&1 &
      else
        notify-send -a "Claude Code" -i utilities-terminal -u normal -t 15000 \
          -h "string:x-canonical-private-synchronous:claude-code-$SESSION" \
          "$title" "$body" >/dev/null 2>&1
      fi
      return 0
      ;;
  esac
  return 0
}

# --- actions ------------------------------------------------------------------
case "$ACTION" in
  focus)
    konsole_focus
    ;;

  clear)
    if [ -f "$STATE_FILE" ]; then
      local_prev="$(cat "$STATE_FILE" 2>/dev/null)"
      rm -f "$STATE_FILE"
      # Dismiss this conversation's pending toast: killing the notify-send
      # client closes it. The synchronous hint carries the session id, so the
      # pattern only ever matches this conversation's watcher.
      pkill -f "x-canonical-private-synchronous:claude-code-$SESSION" >/dev/null 2>&1
      if [ -n "$local_prev" ]; then
        set_title "$local_prev"
      else
        set_title "Claude Code — $PROJECT"
      fi
    fi
    ;;

  *)
    # Read the tab title *before* marking it: that is the conversation topic.
    topic="$(konsole_tab_title)"
    topic="${topic#"$MARKER"}"
    # Strip Konsole's dynamic title decorations ("%d : " prefix, " (%n)" suffix)
    # so the toast shows the topic alone.
    topic="${topic##*" : "}"
    topic="${topic%" ("*")"}"
    topic="${topic# }"
    case "$topic" in
      ""|*"$PROJECT"*) label="${topic:-$PROJECT}" ;;
      *)               label="$topic — $PROJECT" ;;
    esac

    mkdir -p "$STATE_DIR" 2>/dev/null && printf '%s' "$topic" >"$STATE_FILE" 2>/dev/null
    set_title "${MARKER}${topic:-Claude Code — $PROJECT}"

    play_sound &
    notify_desktop "🔔 $label" "$MESSAGE"$'\n'"$CWD"
    ;;
esac

exit 0
