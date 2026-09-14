#!/bin/bash
# Dotfiles installation script

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Git
echo "→ Git configuration..."
ln -sf "$DOTFILES_DIR/git/config" ~/.gitconfig
ln -sf "$DOTFILES_DIR/git/config.personal" ~/.gitconfig.personal

# Claude Code
echo "→ Claude Code configuration..."
mkdir -p ~/.claude
ln -sf "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md

# Claude Code skills
echo "→ Claude Code skills..."
mkdir -p ~/.claude/skills
for skill_dir in "$DOTFILES_DIR/claude/skills"/*/; do
    [ -L "$skill_dir" ] && continue
    skill_name=$(basename "$skill_dir")
    ln -sfn "$skill_dir" ~/.claude/skills/"$skill_name"
done

# Claude Code helper scripts
echo "→ Claude Code helper scripts..."
mkdir -p ~/.local/bin
for script in "$DOTFILES_DIR/claude/bin"/*; do
    ln -sf "$script" ~/.local/bin/"$(basename "$script")"
done

# StreamController
echo "→ StreamController plugin patches..."
"$DOTFILES_DIR/streamcontroller/install.sh"

echo ""
echo "✓ Dotfiles installed"
echo ""
echo "Linked files:"
ls -la ~/.gitconfig ~/.gitconfig.personal ~/.claude/settings.json ~/.claude/CLAUDE.md
echo ""
echo "Helper scripts (ensure ~/.local/bin is in your PATH):"
ls -la ~/.local/bin/claude-seat
echo ""
echo "Skills:"
ls -la ~/.claude/skills/
echo ""
echo "Note: ~/.claude/settings.local.json (permissions) is machine-specific and not synced"
