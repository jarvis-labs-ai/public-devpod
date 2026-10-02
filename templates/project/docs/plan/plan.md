# __NAME__ — plan

<What this is, and the target it is chasing, stated so a command can check it.>

## Hard constraints and invariants (violating any of these is a failed task)

- Never <rule>. <consequence>
- <Pipeline fact agents cannot discover: build image, deploy behaviour, log retention, and where it is verifiable>
- This repository is public. Never commit credentials, internal hostnames, or infrastructure specifics.
- Conflicting instructions: stop and surface the conflict. Never resolve it yourself.
- Blocked: stop, release the bead, comment the blocker. Never wait inside a bead.

## Current state (verified __DATE__)

- Freshly scaffolded: README, AGENTS.md, docs tree, bead store. No code, no tests.
- `scripts/definition-of-done.sh` exits 1 until filled in; no bead can close before Phase 1 fixes that.

## Architecture decisions

| # | Decision | Rationale |
| --- | --- | --- |
| D1 | <decision> | <what it removes the need to re-litigate> |

## Phases

### Phase 1 — scaffold

Depends on: nothing.

| Task | Files |
| --- | --- |
| Fill `AGENTS.md` build/test commands and make `scripts/definition-of-done.sh` run them | `AGENTS.md`, `scripts/definition-of-done.sh` |
| Research note: <the question a wrong guess would hurt most> | `docs/research/<topic>.md` |

Verification: `scripts/definition-of-done.sh` exits 0.

### Phase 2 — <name>

Depends on: Phase 1.

| Task | Files |
| --- | --- |
| <verb-first task> | <every file it writes> |

Verification: <command>

## Open questions

- <A question no phase depends on.>
- DECIDED __DATE__: tracker is bead-rs via NEEDLE; commit trailer is `Bead-Id:`.

## Verification playbook

```bash
scripts/definition-of-done.sh      # → exit 0
```

## Gate log

Record each stage gate here as a dated pass/fail line against the manual's items.

- __DATE__ Stage 1 (scaffold): PASS — tree, README, AGENTS.md, tracker present. Build/test commands pending Phase 1.
