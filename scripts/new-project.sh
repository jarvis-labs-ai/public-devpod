#!/usr/bin/env bash
# Scaffold a new PUBLIC project from templates/project, initialise its tracker,
# create the GitHub repo, push, and register it in projects.txt.
#
#   scripts/new-project.sh <name> [-d "one-line description"] [--org <org>] [--private] [--no-remote]
#
# The result follows the docs-first scaffold (stage 1 of the workflow manual):
# README.md, AGENTS.md, docs/{notes,research,plan/plan.md}, notes/, a bead store.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${1:-}"; shift || true
DESC=""; ORG="${PUBLIC_DEVPOD_ORG:-jarvis-labs-ai}"; VISIBILITY="--public"; REMOTE=1
while [ $# -gt 0 ]; do
  case "$1" in
    -d|--description) DESC="$2"; shift 2 ;;
    --org) ORG="$2"; shift 2 ;;
    --private) VISIBILITY="--private"; shift ;;
    --no-remote) REMOTE=0; shift ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
[[ "$NAME" =~ ^[a-z0-9][a-z0-9._-]*$ ]] || { echo "usage: $0 <name> [-d desc] [--org org] [--private] [--no-remote]  (name: lowercase, digits, . _ -)" >&2; exit 2; }
DEST="$ROOT/projects/$NAME"
[ -e "$DEST" ] && { echo "refusing: $DEST already exists" >&2; exit 1; }
[ -n "$DESC" ] || DESC="$NAME"
TODAY="$(date -u +%F)"

cp -R "$ROOT/templates/project" "$DEST"
# Fill placeholders in every template file.
find "$DEST" -type f -print0 | xargs -0 perl -pi -e "s|__NAME__|$NAME|g; s|__DESCRIPTION__|$DESC|g; s|__ORG__|$ORG|g; s|__DATE__|$TODAY|g"
chmod +x "$DEST/scripts/definition-of-done.sh"

cd "$DEST"
git init -q -b main
if command -v bead >/dev/null 2>&1; then
  bead init --prefix "$NAME" >/dev/null && echo "tracker: bead store initialised (prefix $NAME)"
else
  echo "tracker: 'bead' not on PATH; run 'bead init --prefix $NAME' inside the devpod" >&2
fi
if command -v needle >/dev/null 2>&1; then
  needle init --backend bead-rs >/dev/null 2>&1 && echo "needle: workspace bound to bead-rs" || echo "needle init failed; check 'needle doctor' later" >&2
fi
git add -A
git commit -q -m "chore: scaffold $NAME (docs-first tree, agent instructions, tracker)"

if [ "$REMOTE" -eq 1 ]; then
  gh repo create "$ORG/$NAME" $VISIBILITY --source . --remote origin --push --description "$DESC"
  grep -qx "$ORG/$NAME" "$ROOT/projects.txt" || echo "$ORG/$NAME" >> "$ROOT/projects.txt"
  echo "registered $ORG/$NAME in projects.txt (commit that change in public-devpod)"
else
  echo "no remote created (--no-remote). Later: gh repo create $ORG/$NAME $VISIBILITY --source . --remote origin --push"
fi

cat <<MSG

Created projects/$NAME. Next, in order (docs/notes/workflow.md in public-devpod):
  1. Fill AGENTS.md build/test commands and scripts/definition-of-done.sh.
  2. Write docs/research/*.md for every question you would otherwise guess at.
  3. Write docs/plan/plan.md; have a fresh session cold-read it; fix; repeat until clean.
  4. Decompose into beads with Owns: lines; run scripts/partition-check.sh projects/$NAME.
  5. needle doctor && needle run --agent claude --identifier alpha   (from projects/$NAME)
MSG
