#!/usr/bin/env python3
"""Status line on two rows: who/where, then how much.

Row 1: session name, model (+ advisor), directory, git branch.
Row 2: context gauge, 5h / 7d plan windows.

The advisor is not on the payload. Claude Code stamps `advisorModel` on every
main-thread assistant entry of the transcript while one is active, so the last
such entry is the truth -- including after `/advisor` turned it off. It lags
one turn behind a `/advisor` change, since the next entry carries it.

The gauge is the point. Context size is what actually drives token spend (every
turn re-sends the whole conversation), but it is invisible by default -- you
only notice when auto-compact fires. Showing it makes the drift legible.

The bar fills toward the model's real context window, which Claude Code
reports as `context_window.context_window_size` (1M on Opus 5, 200k elsewhere)
-- hardcoding 200000 painted the bar red on a session that was 5% full.
CLAUDE_CTX_REF overrides it when you want to hold yourself to a tighter budget
than the model allows; past the reference, the readout goes red and stays red.

The 5h / 7d segments mirror `/usage`: percent of the plan window consumed and
how long until it resets, straight from the `rate_limits` field Claude Code
puts on the status-line payload.
"""

import json
import os
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
from ctxlib import (  # noqa: E402
    iter_assistant_entries,
    read_context_tokens,
    read_stdin_payload,
)

RESET = "\033[0m"
DIM = "\033[2m"
BOLD = "\033[1m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
BOLD_RED = "\033[1;31m"
CYAN = "\033[36m"

CTX_REF_OVERRIDE = os.environ.get("CLAUDE_CTX_REF")
CTX_REF_FALLBACK = 200000
BAR_WIDTH = 8
SESSION_NAME_MAX = 32
USER_SETTINGS = os.path.expanduser("~/.claude/settings.json")


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


def model_label(model_id):
    """'claude-opus-5-5' -> 'Opus 5.5'; aliases like 'opus' -> 'Opus'."""
    name = model_id.removeprefix("claude-")
    family, _, version = name.partition("-")
    version = version.split("[")[0].replace("-", ".")
    return f"{family.capitalize()} {version}".strip()


def advisor_model(transcript_path):
    """Active advisor model id, or None when the advisor is off.

    Only the latest main-thread entry counts: an older one carrying the field
    would keep showing an advisor that /advisor has since disabled. With no
    entry in the tail yet (fresh session), fall back to the user setting.
    """
    for entry in iter_assistant_entries(transcript_path):
        return entry.get("advisorModel") or None
    try:
        with open(USER_SETTINGS) as fh:
            return json.load(fh).get("advisorModel") or None
    except (OSError, ValueError):
        return None


def truncate(text, limit):
    return text if len(text) <= limit else text[: limit - 1] + "…"


def compact(tokens):
    if tokens >= 1000000:
        return f"{tokens / 1000000:.10g}M".replace(".0M", "M")
    return f"{tokens // 1000}k"


def context_size(payload):
    """Return (tokens in context, reference window) from the payload.

    `context_window` is authoritative and free; the transcript scan stays as a
    fallback for payloads that predate the field.
    """
    window = payload.get("context_window") or {}
    tokens = window.get("total_input_tokens")
    if not tokens:
        usage = window.get("current_usage") or {}
        tokens = sum(
            usage.get(key, 0)
            for key in (
                "input_tokens",
                "cache_read_input_tokens",
                "cache_creation_input_tokens",
            )
        )
    if not tokens:
        tokens = read_context_tokens(payload.get("transcript_path"))
    if CTX_REF_OVERRIDE:
        ref = int(CTX_REF_OVERRIDE)
    else:
        ref = window.get("context_window_size") or CTX_REF_FALLBACK
    return tokens, ref


def gauge(tokens, ref):
    ratio = tokens / ref
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
    return f"{color}{bar} {compact(tokens)}{DIM}/{compact(ref)}{RESET}"


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

    who = []

    session_name = payload.get("session_name")
    if session_name:
        who.append(f"{BOLD}{truncate(session_name, SESSION_NAME_MAX)}{RESET}")

    model = (payload.get("model") or {}).get("display_name")
    if model:
        advisor = advisor_model(payload.get("transcript_path"))
        tail = f" {DIM}+ advisor {model_label(advisor)}{RESET}" if advisor else ""
        who.append(f"{CYAN}{model}{RESET}{tail}")

    who.append(f"{DIM}{os.path.basename(cwd.rstrip('/')) or '/'}{RESET}")

    branch = git_branch(cwd)
    if branch:
        who.append(f"{DIM}⎇ {branch}{RESET}")

    usage = []

    tokens, ref = context_size(payload)
    usage.append(gauge(tokens, ref) if tokens else f"{DIM}░░░░░░░░ --{RESET}")

    rate_limits = payload.get("rate_limits") or {}
    for label, key in (("5h", "five_hour"), ("7j", "seven_day")):
        segment = limit(label, rate_limits.get(key))
        if segment:
            usage.append(segment)

    sep = f" {DIM}·{RESET} "
    sys.stdout.write(sep.join(who) + "\n" + sep.join(usage))


if __name__ == "__main__":
    main()
