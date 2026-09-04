# StreamController

Fixes for two StreamController plugins installed from its built-in store.

Both are third-party plugins, so this directory holds **patches** rather than
vendored copies: the store overwrites the plugin directory on every update, and
a patch makes it obvious what was changed and why.

## Applying

Run from the repo root:

```bash
./install.sh                 # includes StreamController
./streamcontroller/install.sh  # or just this part
```

Safe to run repeatedly - an already-patched plugin is detected and skipped.
Restart StreamController afterwards; the patched Python is only read at launch.

Uses `git apply`, not `patch(1)` - git is already needed to clone these
dotfiles, whereas `patch` is not installed by default on Fedora.

## What each patch does

### `dev_enjxz_ClaudeUsage` (Claude Code usage)

Pinned to upstream `d241cfe`.

- **New `Claude Limits` action.** Reads `claude -p "/usage"` instead of
  `ccusage`, so the key shows Anthropic's own percentage for the account
  `claude` is logged into, plus the reset time. A dropdown picks the window
  (current session / current week).

  This exists because `ccusage` parses `~/.claude/projects/**/*.jsonl`, and
  those files carry **no account identifier** - after switching between two
  Claude accounts it sums both, with no way to separate them. It also estimates
  usage from raw token counts, while the real limit is based on compute time,
  so any token limit you calibrate drifts as your cache-hit ratio changes.
  `/usage` costs nothing to call (`num_turns: 0`, no model request, ~1.4s).

- **`ClaudeWeeklyUsage` fixed for ccusage 20.x.** It passed `-w <day>`, removed
  upstream, which made every call fail with `Unknown option '-w'`; and it read
  the week-start field as `week`, renamed to `period`.

`ClaudeUsage` (5-hour block) and `ClaudeDailyUsage` are left in place but
unused - keep them if you ever want token counts or a cost in dollars, which
`/usage` does not report.

### `com_ReneLu_spotifyControl` (Spotify)

Pinned to upstream `4125e16`.

Every action cached the plugin's backend reference in its `__init__`:

```python
self.backend = self.plugin_base.backend   # None at this point
```

StreamController builds the actions ~125ms after spawning the backend, but the
backend needs ~250ms to connect - so the snapshot was `None` for the whole
session and every tick logged "Spotify backend is not available", leaving the
keys blank. Replaced with a property that resolves live.

The property needs a **setter**: `ActionCore.__init__` does `self.backend = None`
for actions that spawn their own backend, and a read-only property turns that
into `AttributeError: property 'backend' has no setter` at construction. The
setter ignores the assignment - these actions proxy the plugin's backend.

Each class also declared `backend = None` as a class attribute *after* the
property, which silently shadowed it; those declarations are removed.

## Re-generating a patch after an upstream update

`install.sh` refuses to patch when the plugin's `VERSION` no longer matches the
pinned commit, rather than applying a stale diff. To refresh one:

```bash
PLUGINS=~/.var/app/com.core447.StreamController/data/plugins
git clone https://github.com/<owner>/<repo> /tmp/up
git -C /tmp/up checkout "$(cat $PLUGINS/<plugin>/VERSION)"
# re-apply your changes on top, then:
diff -ruN /tmp/up "$PLUGINS/<plugin>" > patches/<plugin>.patch
```

Exclude `VERSION`, `__pycache__`, `backend/.venv`, and `backend/cache*` - they
are generated locally and are not in the upstream repo.

## Not covered here

- **Plugin settings** (Spotify client ID, redirect port) live in
  `~/.var/app/com.core447.StreamController/data/settings/plugins/` and are not
  synced. Re-enter them via Settings -> Plugins -> Spotify Control -> Open Settings.
- **Key layout** (`data/pages/*.json`) is tied to the deck's serial number, and
  StreamController rewrites it on exit - so it is not synced either.
