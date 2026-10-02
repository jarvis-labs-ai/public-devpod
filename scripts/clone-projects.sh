#!/usr/bin/env bash
# Clone every public repo listed in projects.txt into projects/<name>.
# Safe to re-run: existing clones are left alone (run `git pull` yourself).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT/projects"
{ grep -vE "^\s*(#|$)" "$ROOT/projects.txt" || true; } | while read -r slug; do
  name="${slug##*/}"
  dest="$ROOT/projects/$name"
  if [ -d "$dest/.git" ]; then echo "exists: projects/$name"; continue; fi
  echo "clone:  $slug -> projects/$name"
  git clone --quiet "https://github.com/$slug.git" "$dest"
done
