#!/usr/bin/env bash
# Symlink this fork's skills into ~/.claude/skills (idempotent).
# Edit KEEP to choose which skills are active. Never touches non-symlinks
# or links pointing outside this repo (e.g. Omarchy's).
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
DEST="${SKILLS_DEST:-$HOME/.claude/skills}"
KEEP=(
  # engineering
  ask-matt codebase-design matt-code-review diagnosing-bugs domain-modeling
  grill-with-docs implement implement-spec improve-codebase-architecture pr
  prototype research retro setup-matt-pocock-skills tdd to-spec to-tickets
  triage wayfinder wizard
  # productivity
  grilling grill-me handoff teach to-questionnaire wait-what writing-for-agents
)
mkdir -p "$DEST"
# Remove stale links that point into this repo but are no longer kept.
for link in "$DEST"/*; do
  [[ -L $link ]] || continue
  target="$(readlink "$link")"
  [[ $target == "$REPO"/* ]] || continue
  name="$(basename "$link")"
  [[ " ${KEEP[*]} " == *" $name "* && -e $link ]] || { rm "$link"; echo "unlinked $name"; }
done
for name in "${KEEP[@]}"; do
  src=""
  for d in engineering productivity; do [[ -d $REPO/skills/$d/$name ]] && src="$REPO/skills/$d/$name"; done
  [[ -n $src ]] || { echo "missing: $name" >&2; continue; }
  if [[ -e $DEST/$name && ! -L $DEST/$name ]]; then echo "skip $name (real dir exists)" >&2; continue; fi
  ln -sfn "$src" "$DEST/$name"
done
echo "linked ${#KEEP[@]} skills into $DEST"
