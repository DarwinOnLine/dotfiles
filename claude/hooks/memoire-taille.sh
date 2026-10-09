#!/usr/bin/env bash
# SessionStart : avertit quand l'index de mémoire du projet courant dépasse 20 000 octets
# (limite de chargement : 24,4 Ko, au-delà les dernières lignes ne sont plus lues).
seuil=20000
cwd=$(jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd=$PWD
index="$HOME/.claude/projects/$(printf '%s' "$cwd" | sed 's|[/.]|-|g')/memory/MEMORY.md"
[ -f "$index" ] || exit 0
taille=$(wc -c < "$index")
[ "$taille" -gt "$seuil" ] || exit 0
msg="MEMORY.md fait ${taille} octets (seuil ${seuil}, limite de chargement ~24 400) : proposer le ménage de la mémoire à l'utilisateur (règle menage-memoire-regulier)."
jq -n --arg m "$msg" '{systemMessage: $m, hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $m}}'
