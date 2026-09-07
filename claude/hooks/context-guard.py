#!/usr/bin/env python3
"""UserPromptSubmit hook: nudge toward /clear when the context has grown large.

Why a hook and not an instruction in CLAUDE.md: the model cannot see its own
context size. Only the transcript knows. So the hook measures and the model
judges -- it decides whether this is a natural task boundary and writes the
resume line. That division matters: a /clear mid-task costs more than it saves,
because the context has to be rebuilt by hand.

Fires at most once per threshold band per session, so it nudges instead of
nagging. Thresholds are overridable via CLAUDE_CTX_BANDS (comma-separated
token counts).
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
from ctxlib import read_context_tokens, read_stdin_payload  # noqa: E402

DEFAULT_BANDS = "150000,300000,550000"
STATE_DIR = os.path.expanduser("~/.claude/cache/ctx-guard")

ADVICE = {
    0: (
        "The context has passed {k}k tokens. Every further turn re-sends all of "
        "it, so cost now grows faster than the work does."
    ),
    1: (
        "The context has passed {k}k tokens -- roughly double a healthy working "
        "size, and past the long-context pricing tier."
    ),
    2: (
        "The context has passed {k}k tokens. This session is now one of the "
        "expensive ones; nearly all of that spend is re-reading history."
    ),
}

INSTRUCTION = """\
{advice}

Act on this ONLY if the work is at a natural boundary -- a task finished, a \
question answered, a subject about to change. If you are mid-task, say nothing \
about it and carry on; an interruption here would cost more than it saves.

If it IS a boundary, finish answering the user first, then add a short closing \
suggestion: recommend `/clear` and give a single-line resume prompt they can \
paste into the fresh session. That line must carry only what a new session \
could not recover on its own -- the current objective, decisions already \
settled, approaches already ruled out. Not a summary of what was done; the \
code and git history already hold that.

Mention this once. Do not repeat it in later turns unless the user asks."""


def bands():
    raw = os.environ.get("CLAUDE_CTX_BANDS", DEFAULT_BANDS)
    try:
        return sorted(int(x) for x in raw.split(",") if x.strip())
    except ValueError:
        return sorted(int(x) for x in DEFAULT_BANDS.split(","))


def band_index(tokens, thresholds):
    """Highest band crossed, or -1 if below them all."""
    crossed = -1
    for i, threshold in enumerate(thresholds):
        if tokens >= threshold:
            crossed = i
    return crossed


def state_path(session_id):
    return os.path.join(STATE_DIR, f"{session_id}.band")


def already_fired(session_id):
    try:
        with open(state_path(session_id)) as fh:
            return int(fh.read().strip())
    except (OSError, ValueError):
        return -1


def record(session_id, index):
    try:
        os.makedirs(STATE_DIR, exist_ok=True)
        with open(state_path(session_id), "w") as fh:
            fh.write(str(index))
    except OSError:
        pass  # a nudge lost to a read-only cache dir is not worth failing over


def main():
    payload = read_stdin_payload()
    session_id = payload.get("session_id")
    tokens = read_context_tokens(payload.get("transcript_path"))
    if not tokens or not session_id:
        return

    thresholds = bands()
    index = band_index(tokens, thresholds)
    fired = already_fired(session_id)

    if index < fired:
        # The context shrank -- a /compact ran. Re-arm the lower bands so the
        # next climb is caught again.
        record(session_id, index)
        return
    if index < 0 or index == fired:
        return

    record(session_id, index)
    advice = ADVICE[min(index, max(ADVICE))].format(k=tokens // 1000)
    print(
        json.dumps(
            {
                "suppressOutput": True,
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": INSTRUCTION.format(advice=advice),
                },
            }
        )
    )


if __name__ == "__main__":
    main()
