#!/usr/bin/env bash
# Claude Code attention notifier.
#
# Usage (from settings.json hooks):
#   notify-attention.sh notify   -> Notification hook: sound + desktop toast + title marker
#   notify-attention.sh clear    -> UserPromptSubmit / Stop hook: remove the title marker
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
PROJECT="$(basename "${CLAUDE_PROJECT_DIR:-$PWD}")"

# Per-session flag, so `clear` only restores a title we actually marked.
SESSION="$(json '.session_id')"
[ -n "$SESSION" ] || SESSION="${CLAUDE_SESSION_ID:-unknown}"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/claude-notify"
STATE_FILE="$STATE_DIR/$SESSION"

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

# --- window / tab title -------------------------------------------------------
# Hook stdout is captured by Claude Code, so escape sequences must go straight
# to the controlling terminal. Two sequences are emitted:
#   OSC 0  -> icon name + window title (all terminals; Claude Code's TUI may
#             later overwrite it when it refreshes its own title)
#   OSC 30 -> Konsole/Yakuake tab title, which Claude Code never touches, so
#             the marker sticks on the tab even if OSC 0 gets clobbered.
tty_write() {
  ( exec 2>/dev/null; printf '%b' "$1" >/dev/tty ) || true
}

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
  # Last resort: terminal bell.
  tty_write '\a'
}

# --- desktop notification -----------------------------------------------------
notify_desktop() {
  local title="Claude Code — $PROJECT"
  case "$PLATFORM" in
    macos)
      if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier -title "$title" -message "$MESSAGE" -sound Ping >/dev/null 2>&1 && return 0
      fi
      osascript -e "display notification \"${MESSAGE//\"/\\\"}\" with title \"$title\"" \
        >/dev/null 2>&1 && return 0
      ;;
    wsl)
      command -v notify-send.exe >/dev/null 2>&1 \
        && notify-send.exe "$title" "$MESSAGE" >/dev/null 2>&1 && return 0
      command -v wsl-notify-send.exe >/dev/null 2>&1 \
        && wsl-notify-send.exe --category "$title" "$MESSAGE" >/dev/null 2>&1 && return 0
      # Fallback: WinForms balloon tip, no extra dependency.
      powershell.exe -NoProfile -Command "
        Add-Type -AssemblyName System.Windows.Forms
        \$n = New-Object System.Windows.Forms.NotifyIcon
        \$n.Icon = [System.Drawing.SystemIcons]::Information
        \$n.BalloonTipTitle = '$title'
        \$n.BalloonTipText  = '${MESSAGE//\'/\'\'}'
        \$n.Visible = \$true
        \$n.ShowBalloonTip(10000)
        Start-Sleep -Seconds 6
        \$n.Dispose()" >/dev/null 2>&1 &
      return 0
      ;;
    *)
      # -a groups notifications in the KDE tray; -h replace-id collapses repeats.
      command -v notify-send >/dev/null 2>&1 && notify-send \
        -a "Claude Code" \
        -i utilities-terminal \
        -u normal \
        -t 15000 \
        -h string:x-canonical-private-synchronous:claude-code \
        "$title" "$MESSAGE" >/dev/null 2>&1 && return 0
      ;;
  esac
  return 0
}

PLATFORM="$(platform)"

case "$ACTION" in
  clear)
    if [ -f "$STATE_FILE" ]; then
      rm -f "$STATE_FILE"
      set_title "Claude Code — $PROJECT"
    fi
    ;;
  *)
    mkdir -p "$STATE_DIR" 2>/dev/null && : >"$STATE_FILE" 2>/dev/null
    set_title "🔔 Claude Code — $PROJECT"
    play_sound &
    notify_desktop
    ;;
esac

exit 0
