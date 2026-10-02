# AGENTS.md

Standing rules for working in this repository. The plan lives at
`docs/plan/plan.md`; this file holds the parts that do not change.

## Build and test

- Build: `<exact command, flags included>`
- Test: `<exact command, copy-pasteable>`
- Definition of done: `scripts/definition-of-done.sh` must exit 0. NEEDLE runs it against committed HEAD before accepting any close; it fails until it is filled in.

## Commits

- Style: `type(scope): summary` (`feat`, `fix`, `chore`, `docs`, `test`).
- Trailer: every commit carries `Bead-Id: <id>` for the bead it belongs to. One bead, one commit.
- Never force-push. A pushed branch is shared state; reconcile with a merge commit.
- Never commit build artifacts, secrets, or `.beads/beads.db`. This repository is public; committing a credential is a failed task.
- Never use `git commit --no-verify`.

## Work queue

- The tracker is `bead` (bead-rs) in `.beads/`. Claim a bead before starting it (`bead claim --assignee <you>`); never work an unclaimed bead.
- Write only files listed on the bead's `Owns:` line. Reading anything is fine. Needing a file outside the list means stop, release, and comment naming the file. Do not take the file.
- Close a bead only once every acceptance criterion has been run and passes: `bead close <id> --reason "<which commands passed>"`.
- Write a short work log to `notes/<bead-id>.md`: what you understood, tried, and found. Never edit another bead's note.

## When blocked

Stop. Release the bead (`bead release <id>`). Comment describing the blocker (`bead update <id> --notes "..."`). Do not wait inside a bead, and do not improvise around a blocker. If two instructions conflict, stop and surface the conflict; never resolve it yourself.
