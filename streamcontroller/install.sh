#!/bin/bash
# StreamController plugin patches.
#
# Both plugins are installed from StreamController's built-in store, which
# overwrites the plugin directory on every update - so the fixes live here as
# patches rather than as vendored copies, and get re-applied after each update.
#
# Safe to run repeatedly: an already-patched plugin is detected and skipped.
#
# Uses `git apply` rather than `patch(1)`: git is already required to clone these
# dotfiles, whereas patch is not installed by default on Fedora.

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Store commit each patch was generated against (matches the plugin's VERSION file).
declare -A PINNED=(
    [dev_enjxz_ClaudeUsage]=d241cfe4babb0b176060e7f65d0578ead586ad1e
    [com_ReneLu_spotifyControl]=4125e16a261bbbe26d5e19280bf163bc3026192e
)

for candidate in \
    "$HOME/.var/app/com.core447.StreamController/data/plugins" \
    "$HOME/.local/share/StreamController/plugins"
do
    [ -d "$candidate" ] && PLUGINS="$candidate" && break
done

if [ -z "${PLUGINS:-}" ]; then
    echo "  ! StreamController plugin directory not found - skipping"
    echo "    (install StreamController and the plugins from its store first)"
    exit 0
fi

echo "  plugins: $PLUGINS"
rc=0

for plugin in "${!PINNED[@]}"; do
    target="$PLUGINS/$plugin"
    patch_file="$DIR/patches/$plugin.patch"

    if [ ! -d "$target" ]; then
        echo "  - $plugin: not installed, skipped (install it from the store)"
        continue
    fi

    # Already applied? A reverse dry-run succeeds only on a patched tree.
    if git -C "$target" apply -p1 --reverse --check "$patch_file" 2>/dev/null; then
        echo "  = $plugin: already patched"
        continue
    fi

    installed=$(cat "$target/VERSION" 2>/dev/null || echo "unknown")
    if [ "$installed" != "${PINNED[$plugin]}" ]; then
        echo "  ! $plugin: store version moved"
        echo "      installed: $installed"
        echo "      patch for: ${PINNED[$plugin]}"
        echo "      Re-generate the patch against the new upstream before applying."
        rc=1
        continue
    fi

    if git -C "$target" apply -p1 --check "$patch_file" 2>/dev/null; then
        git -C "$target" apply -p1 "$patch_file"
        # Stale bytecode would shadow the patched sources on the next launch.
        find "$target" -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null
        echo "  + $plugin: patched"
    else
        echo "  ! $plugin: patch does not apply cleanly - left untouched"
        rc=1
    fi
done

[ $rc -eq 0 ] && echo "  Restart StreamController to load the patched plugins."
exit $rc
