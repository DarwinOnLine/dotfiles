"""Shared helper: read the current context size from a Claude Code transcript.

Claude Code appends one JSON object per line to the session transcript. Each
assistant message carries a `message.usage` block; the sum of its input,
cache-read and cache-creation tokens is what that request actually cost, which
is the best available proxy for "how big is the context right now".

The file can reach tens of MB, and this runs on every status-line refresh, so
we read a bounded tail and scan backwards for the most recent usage block.
"""

import json
import os

TAIL_BYTES = 262144


def read_context_tokens(transcript_path):
    """Return the context size (tokens) of the last API request, or None."""
    if not transcript_path or not os.path.isfile(transcript_path):
        return None
    try:
        size = os.path.getsize(transcript_path)
        with open(transcript_path, "rb") as fh:
            if size > TAIL_BYTES:
                fh.seek(size - TAIL_BYTES)
                fh.readline()  # discard the partial line we landed in
            chunk = fh.read()
    except OSError:
        return None

    for line in reversed(chunk.splitlines()):
        line = line.strip()
        if not line.startswith(b"{"):
            continue
        try:
            entry = json.loads(line)
        except ValueError:
            continue
        if entry.get("type") != "assistant":
            continue
        usage = (entry.get("message") or {}).get("usage") or {}
        total = (
            usage.get("input_tokens", 0)
            + usage.get("cache_read_input_tokens", 0)
            + usage.get("cache_creation_input_tokens", 0)
        )
        if total:
            return total
    return None


def read_stdin_payload():
    """Parse the hook/status-line JSON payload from stdin, tolerating garbage."""
    import sys

    try:
        return json.loads(sys.stdin.read() or "{}")
    except ValueError:
        return {}
