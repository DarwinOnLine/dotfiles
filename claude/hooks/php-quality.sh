#!/usr/bin/env bash
#
# php-quality.sh — runs the project's PHP quality tools on one edited file.
#
# Called by the PostToolUse hook in claude/settings.json. Exists because PHP is
# not always installed natively: on a Docker-only machine, `php vendor/bin/...`
# fails with "env: php: No such file or directory" and, being piped into head,
# fails *silently*. This resolves a usable PHP runtime first, then runs only the
# tools the project actually installs.
#
# Usage: php-quality.sh <path-to-php-file>
# Always exits 0 — a quality report must never block an edit.

set -u

file="${1:-}"
[ -n "$file" ] || exit 0

# Tool configs and vendor/ are looked up relative to the project root, which is
# the hook's cwd. Container workdirs mirror it, so a relative path is valid on
# both sides of the Docker boundary.
rel="${file#"$PWD"/}"

running_services() {
    docker compose ps --services --status running 2>/dev/null
}

# Resolve how to invoke a PHP binary here, cheapest option first.
if command -v php >/dev/null 2>&1; then
    php_run() { php "$@"; }
elif ! command -v docker >/dev/null 2>&1; then
    exit 0
elif [ -x bin/docker.sh ] && running_services | grep -qx php; then
    # Project wrapper around docker compose (handles its own --env-file).
    php_run() { bin/docker.sh exec -T php php "$@"; }
elif [ -x vendor/bin/sail ] && running_services | grep -qx laravel.test; then
    php_run() { docker compose exec -T laravel.test php "$@"; }
else
    # No usable runtime — stay silent rather than reporting a phantom failure.
    exit 0
fi

for cfg in phpstan.neon phpstan.neon.dist phpstan.dist.neon; do
    [ -f "$cfg" ] || continue
    [ -f vendor/bin/phpstan ] || break
    php_run vendor/bin/phpstan analyse --no-progress --error-format=raw "$rel" 2>&1 | head -20
    break
done

if [ -f vendor/bin/pint ]; then
    # Report only on failure: Pint prints a PASS banner otherwise, and this hook
    # fires on every edit.
    if ! pint_out=$(php_run vendor/bin/pint --test "$rel" 2>&1); then
        printf '%s\n' "$pint_out" | head -20
    fi
fi

exit 0
