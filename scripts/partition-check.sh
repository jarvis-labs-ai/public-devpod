#!/usr/bin/env bash
# Stage 5 gate: every file named by more than one READY bead's "Owns:" line.
# Silence is the good output. Any line printed is a missing dependency edge or a
# task that should be split. Run before launching more than one worker.
#   scripts/partition-check.sh [path-to-project]   (default: current directory)
set -euo pipefail
cd "${1:-.}"
command -v bead >/dev/null || { echo "bead not on PATH" >&2; exit 2; }
command -v jq >/dev/null || { echo "jq not on PATH" >&2; exit 2; }
# One "file bead-id" pair per line, scraped from each ready bead's description/notes.
pairs="$(bead list --ready --json 2>/dev/null | jq -r '
  .id as $i
  | ((.description // "") + "\n" + (.notes // ""))
  | split("\n")[]
  | select(test("^Owns:"))
  | sub("^Owns: *"; "") | gsub(","; " ") | split(" ")[]
  | select(length > 0) | "\(.) \($i)"' | sort || true)"
printf '%s\n' "$pairs" | awk 'NF{f[$1]=f[$1]" "$2; c[$1]++} END{for(k in c) if(c[k]>1) print k":"f[k]}'
total=$(printf '%s\n' "$pairs" | awk 'NF{print $1}' | sort -u | grep -c . || true)
contended=$(printf '%s\n' "$pairs" | awk 'NF{print $1}' | sort | uniq -d | grep -c . || true)
echo "$contended/$total owned files contended across ready beads" >&2
