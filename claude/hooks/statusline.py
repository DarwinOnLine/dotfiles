#!/usr/bin/env python3
"""Status line: model, directory, git branch, and a context-size gauge.

The gauge is the point. Context size is what actually drives token spend (every
turn re-sends the whole conversation), but it is invisible by default -- you
only notice when auto-compact fires. Showing it makes the drift legible.

CLAUDE_CTX_REF sets the reference window in tokens (default 200000). The bar
fills toward it; past it, the readout goes red and stays red.

The 5h / 7d segments mirror `/usage`: percent of the plan window consumed and
how long until it resets, straight from the `rate_limits` field Claude Code
puts on the status-line payload.
"""

import os
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
from ctxlib import read_context_tokens, read_stdin_payload  # noqa: E402

RESET = "\033[0m"
DIM = "\033[2m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
BOLD_RED = "\033[1;31m"
CYAN = "\033[36m"

REF = int(os.environ.get("CLAUDE_CTX_REF", "200000"))
BAR_WIDTH = 8


def git_branch(cwd):
    try:
        out = subprocess.run(
            ["git", "-C", cwd, "symbolic-ref", "--quiet", "--short", "HEAD"],
            capture_output=True,
            text=True,
            timeout=1,
        )
        return out.stdout.strip() or None
    except (OSError, subprocess.SubprocessError):
        return None


def gauge(tokens):
    ratio = tokens / REF
    filled = min(BAR_WIDTH, int(ratio * BAR_WIDTH))
    bar = "█" * filled + "░" * (BAR_WIDTH - filled)
    if ratio < 0.5:
        color = GREEN
    elif ratio < 0.8:
        color = YELLOW
    elif ratio < 1.0:
        color = RED
    else:
        color = BOLD_RED
    return f"{color}{bar} {tokens // 1000}k{RESET}"


def human_delta(ts):
    """Compact 'time until' rendering for a unix timestamp."""
    secs = int(ts - time.time())
    if secs <= 0:
        return "0m"
    days, rem = divmod(secs, 86400)
    hours, minutes = divmod(rem // 60, 60)
    if days:
        return f"{days}j{hours}h"
    if hours:
        return f"{hours}h{minutes:02d}"
    return f"{minutes}m"


def limit(label, window):
    """Render one rate-limit window: label, percent used, time to reset."""
    if not isinstance(window, dict):
        return None
    pct = window.get("used_percentage")
    if pct is None:
        return None
    if pct < 60:
        color = GREEN
    elif pct < 85:
        color = YELLOW
    else:
        color = RED
    resets_at = window.get("resets_at")
    tail = f" {DIM}↻{human_delta(resets_at)}{RESET}" if resets_at else ""
    return f"{color}{label} {round(pct)}%{RESET}{tail}"


def main():
    payload = read_stdin_payload()
    cwd = (
        payload.get("cwd")
        or payload.get("workspace", {}).get("current_dir")
        or os.getcwd()
    )

    parts = []

    model = (payload.get("model") or {}).get("display_name")
    if model:
        parts.append(f"{CYAN}{model}{RESET}")

    parts.append(f"{DIM}{os.path.basename(cwd.rstrip('/')) or '/'}{RESET}")

    branch = git_branch(cwd)
    if branch:
        parts.append(f"{DIM}⎇ {branch}{RESET}")

    tokens = read_context_tokens(payload.get("transcript_path"))
    parts.append(gauge(tokens) if tokens else f"{DIM}░░░░░░░░ --{RESET}")

    rate_limits = payload.get("rate_limits") or {}
    for label, key in (("5h", "five_hour"), ("7j", "seven_day")):
        segment = limit(label, rate_limits.get(key))
        if segment:
            parts.append(segment)

    sys.stdout.write(f" {DIM}·{RESET} ".join(parts))


if __name__ == "__main__":
    main()
