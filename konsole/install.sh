#!/bin/bash
# Konsole: profile "Darwin" (copy on select) + Ctrl+V paste shortcut.
#
# Konsole only exists on Linux/KDE; anywhere else this is a no-op. The same
# behaviour on other terminals is documented in the README instead.
#
# konsolerc is NOT symlinked: Konsole writes window state into it. Only the
# DefaultProfile key is set, through kwriteconfig.

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(uname -s)" != "Linux" ] || ! command -v konsole >/dev/null 2>&1; then
    echo "  - Konsole not installed, skipped"
    exit 0
fi

mkdir -p ~/.local/share/konsole ~/.local/share/kxmlgui5/konsole
ln -sf "$DIR/Darwin.profile" ~/.local/share/konsole/Darwin.profile
ln -sf "$DIR/sessionui.rc" ~/.local/share/kxmlgui5/konsole/sessionui.rc

kwriteconfig=$(command -v kwriteconfig6 || command -v kwriteconfig5)
if [ -n "$kwriteconfig" ]; then
    "$kwriteconfig" --file konsolerc --group 'Desktop Entry' --key DefaultProfile Darwin.profile
else
    echo "  ! kwriteconfig not found: set Darwin as default profile in Konsole by hand"
fi

echo "  + Konsole linked (restart every Konsole window to apply)"
