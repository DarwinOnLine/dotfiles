#!/usr/bin/env python3
"""Status line: model, directory, git branch, and a context-size gauge.

The gauge is the point. Context size is what actually drives token spend (every
turn re-sends the whole conversation), but it is invisible by default -- you
only notice when auto-compact fires. Showing it makes the drift legible.

CLAUDE_CTX_REF sets the reference window in tokens (default 200000). The bar
fills toward it; past it, the readout goes red and stays red.
"""

import os
import subprocess
import sys

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

    sys.stdout.write(f" {DIM}·{RESET} ".join(parts))


if __name__ == "__main__":
    main()
