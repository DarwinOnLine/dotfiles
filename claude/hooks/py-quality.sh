#!/usr/bin/env bash
#
# py-quality.sh — runs Ruff on one edited Python file.
#
# Called by the PostToolUse hook in claude/settings.json. Mirrors the contract of
# php-quality.sh: report only, never rewrite the file, always exit 0 — a quality
# report must never block an edit.
#
# Runs only when a Ruff config is found by walking up from the file, so editing
# Python in an unrelated project stays silent instead of emitting findings nobody
# asked for. Walking up from the file (rather than from $PWD) matches how Ruff
# itself discovers config, and is what makes this work regardless of the session
# cwd — the hook's cwd is the session directory, not the file's project root.
#
# Usage: py-quality.sh <path-to-python-file>

set -u

file="${1:-}"
[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0

has_ruff_config() {
    local dir
    dir=$(cd "$(dirname "$1")" 2>/dev/null && pwd) || return 1
    while :; do
        [ -f "$dir/ruff.toml" ] && return 0
        [ -f "$dir/.ruff.toml" ] && return 0
        # pyproject.toml only counts when it actually configures Ruff.
        [ -f "$dir/pyproject.toml" ] && grep -q '^\[tool\.ruff' "$dir/pyproject.toml" && return 0
        [ "$dir" = "/" ] && return 1
        dir=$(dirname "$dir")
    done
}

has_ruff_config "$file" || exit 0

# Prefer an installed ruff; fall back to uvx so a freshly cloned dotfiles still
# lints without a manual install step.
if command -v ruff >/dev/null 2>&1; then
    ruff_run() { ruff "$@"; }
elif command -v uvx >/dev/null 2>&1; then
    ruff_run() { uvx ruff "$@"; }
else
    exit 0
fi

ruff_run check --quiet "$file" 2>&1 | head -20

# --check reports without writing, matching `pint --test` in php-quality.sh.
if ! fmt_out=$(ruff_run format --check --quiet "$file" 2>&1); then
    printf '%s\n' "$fmt_out" | head -5
fi

exit 0
