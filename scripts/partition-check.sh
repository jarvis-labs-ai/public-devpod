#!/usr/bin/env bash
# Stage 5 gate: every file named by more than one READY bead's "Owns:" line.
# Silence is the good output. Any line printed is a missing dependency edge or a
# task that should be split. Run before launching more than one worker.
#   scripts/partition-check.sh [path-to-project]   (default: current directory)
set -euo pipefail
cd "${1:-.}"
command -v bead >/dev/null || { echo "bead not on PATH" >&2; exit 2; }
ids="$(bead list --ready --json 2>/dev/null | jq -r '.id' || true)"
[ -n "$ids" ] || { echo "no ready beads"; exit 0; }
pairs="$(for id in $ids; do
  bead show "$id" | awk -v id="$id" '/^Owns:/{sub(/^Owns: */,""); gsub(/,/,""); for(i=1;i<=NF;i++) print $i, id}'
done | sort)"
printf '%s\n' "$pairs" | awk 'NF{f[$1]=f[$1]" "$2; c[$1]++} END{for(k in c) if(c[k]>1) print k":"f[k]}'
total=$(printf '%s\n' "$pairs" | awk 'NF{print $1}' | sort -u | wc -l | tr -d ' ')
contended=$(printf '%s\n' "$pairs" | awk 'NF{print $1}' | sort | uniq -d | wc -l | tr -d ' ')
echo "$contended/$total files contended" >&2
