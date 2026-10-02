#!/usr/bin/env bash
# Definition of Done: the commands that must pass before a bead may close.
# NEEDLE runs this on a clean `git archive HEAD` extraction (committed state only).
# Fails closed until the real build + test commands from AGENTS.md are put here.
set -euo pipefail
echo "definition-of-done.sh: not configured yet; add the build and test commands from AGENTS.md" >&2
exit 1
