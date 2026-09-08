# StreamController

Fixes for two StreamController plugins installed from its built-in store.

Both come from the store, so this directory holds **patches** rather than
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

### `com_core447_MicMute` (microphone mute)

Pinned to upstream `f7eb954`.

Both the mute toggle and the state shown on the key iterated over
`pulse.source_list()`, which includes **monitor sources** - the virtual capture
device every output exposes so that screen recorders can grab desktop audio.

The plugin only knows how to target a device by `device.nick`, and on this
machine that does not discriminate: the two microphones and the speaker plus
four HDMI monitors of the Ryzen HD Audio controller all report
`HD-Audio Generic`. Two consequences:

- muting "the mic" also muted desktop capture, silently;
- `get_mute_state` returns early on its first nickname match, which was
  whichever source `source_list()` happened to yield first - a monitor as
  often as a mic - so the key showed the wrong state. With `all` set instead,
  a single disagreeing source makes it return `None` and the key renders its
  error icon, which a Bluetooth headset or an AirPlay sink connecting is
  enough to trigger.

Fixed with an `input_sources()` helper that drops anything whose name ends in
`.monitor`, used by the toggle, the state read and the device dropdown. The
key is configured with `all` - after the filter that means both real
microphones and nothing else.

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

- **Plugin settings** live in
  `~/.var/app/com.core447.StreamController/data/settings/plugins/` and are not
  synced. Re-enter them via Settings -> Plugins -> <plugin> -> Open Settings.
- **`com_core447_MediaPlugin`** (now playing, over MPRIS) is installed from the
  store unpatched, so it is not listed here - it needs no fix.
- **Key layout** (`data/pages/*.json`) is tied to the deck's serial number, and
  StreamController rewrites it on exit - so it is not synced either.
