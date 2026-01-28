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

echo ""
echo "✓ Dotfiles installed"
echo ""
echo "Linked files:"
ls -la ~/.gitconfig ~/.gitconfig.personal ~/.claude/settings.json ~/.claude/CLAUDE.md
echo ""
echo "Note: ~/.claude/settings.local.json (permissions) is machine-specific and not synced"
