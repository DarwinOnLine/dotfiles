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
│   └── settings.json    # Attribution settings
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
