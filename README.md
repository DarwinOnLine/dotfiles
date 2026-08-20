# Dotfiles

Personal configuration files for development tools.

## Contents

- **Git** - Global config with automatic personal identity for `**/Projets/Perso/**`
- **Claude Code** - AI assistant configuration (instructions, attribution settings)

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
│   ├── hooks/           # Scripts called by settings.json hooks
│   └── skills/          # Personal skills, symlinked into ~/.claude/skills
└── install.sh           # Symlink installer
```

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
