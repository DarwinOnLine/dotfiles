# Dotfiles

Personal configuration files for development tools.

## Contents

- **Git** - Global config with automatic personal identity for `**/Projets/Perso/**`
- **Claude Code** - AI assistant configuration (instructions, attribution settings)
- **StreamController** - patches for two Stream Deck plugins installed from its store

## Installation

```bash
git clone git@github.com:DarwinOnLine/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Structure

```
dotfiles/
├── git/
│   ├── config           # Global .gitconfig
│   └── config.personal  # Personal identity (DarwinOnLine)
├── claude/
│   ├── CLAUDE.md        # Global instructions
│   ├── settings.json    # Attribution, hooks, editor settings
│   ├── bin/             # Helper CLIs, symlinked into ~/.local/bin
│   ├── hooks/           # Scripts called by settings.json hooks
│   └── skills/          # Personal skills, symlinked into ~/.claude/skills
├── streamcontroller/
│   ├── patches/         # Diffs against the store-installed plugins
│   └── install.sh       # Applies them, idempotent
└── install.sh           # Symlink installer
```

## Switching between Claude Code accounts

`claude/bin/claude-seat` swaps the OAuth session stored in
`~/.claude/.credentials.json`, so several Claude accounts can share one machine
without a browser logout/login each time.

```bash
claude-seat setup                          # guided first-time instructions
claude-seat login work you@company.com     # sign in, then capture as seat "work"
claude-seat list                           # '*' marks the active seat
claude-seat work                           # switch; running sessions follow along
```

A seat holds both halves of an identity: the tokens from
`~/.claude/.credentials.json` and the `oauthAccount` block of `~/.claude.json`.
Swapping only the first leaves `claude auth status` reporting the wrong account.

The browser step of `login` needs a session that is *not* already signed in to
the other account, otherwise it silently re-authenticates the same one. Use
`BROWSER=firefox-private claude-seat login …` (wrapper in `claude/bin/`), or a
dedicated Firefox profile via `firefox -P`.

Seats live in `~/.claude/seats/` — tokens and identities are machine-local and
never committed here.

## Git identities

| Path pattern | Identity |
|--------------|----------|
| `**/Projets/Perso/**` | DarwinOnLine |
| `**/dotfiles/**` | DarwinOnLine |
| Everything else | Matthieu Poignant (pro) |

## Notes

- `~/.claude/settings.local.json` (permissions) is machine-specific and not synced
- Run `./install.sh` after pulling updates to refresh symlinks
- `claude/hooks/php-quality.sh` resolves a PHP runtime before running PHPStan and Pint.
  PHP is not installed natively on every machine — this machine runs it through
  Docker — so the script falls back to the project's container and stays silent
  when no runtime is available.
- Sub-agents and the `/chiffrage` skill live in a separate repo, `dev-assistant`,
  to avoid overlapping with the BeHigh team bundle (`dev-workflow`).
- `streamcontroller/` patches store-installed plugins instead of symlinking them —
  the store overwrites its plugin directory on update. Re-run `./install.sh` after
  a plugin update; it refuses to apply a patch whose pinned upstream commit moved.
  See `streamcontroller/README.md`.
