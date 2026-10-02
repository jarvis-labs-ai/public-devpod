# The workflow, condensed

Source: https://jedarden.com/guides/workflow/ (the manual; read it once in full).
Seven stages. Each produces a file the next consumes; nothing passes between
stages as conversation. Each ends in a gate you check, not judge, and the
verdict is recorded as a dated line in `docs/plan/plan.md`.

A worker gets exactly three things per dispatch: the task specification, the
repository, and `AGENTS.md`. A decision not in one of those does not exist.

## 1. Scaffold (`scripts/new-project.sh` does this)

`README.md` (purpose, two paragraphs), `AGENTS.md` (standing rules as
absolutes: build/test commands, commit trailer, never-rules, how to claim,
what to do when blocked), `docs/notes/` (curated), `docs/research/`,
`docs/plan/plan.md`, `notes/` (agent-written, one file per bead; never edited),
tracker initialised.

## 2. Research

One markdown file per question you would otherwise guess at, in
`docs/research/`: the question, what you found (with a command and its
output), what it means for the design, what is still unknown. Depth tracks how
quietly a wrong assumption fails. Anything unanswerable by reading becomes a
timeboxed spike task, never an assumption. These notes are where
command-verifiable acceptance criteria come from.

## 3. One plan file

`docs/plan/plan.md`, seven parts: overview with the measurable target; hard
constraints phrased as absolutes ("never X", with the consequence); current
state with a verification date; architecture decisions as a table; phases
ordered by dependency, every task naming its files; open questions (only
genuinely deferred things; decided ones stay, marked DECIDED <date>); a
verification playbook of commands with expected output.

## 4. Review (the highest-leverage hour)

Dispatch to a fresh session that did not write the plan:
- Structural pass: "For each task, could an agent execute this as written with
  only the repository for context? If not, name the missing file, model,
  decision, or command. Do not propose designs."
- Separate gap hunt: "Find what is missing entirely: sections, decisions a
  phase assumes, behaviour no task implements, data never defined."
Fix, re-run both, until a pass returns nothing. Exit condition is a number:
zero undeliverable tasks.

## 5. Decompose (this is the concurrency plan)

A genesis bead per project. One deliverable and one acceptance command per
bead; under ~3,000 characters; fewer than eight criteria; every criterion a
command. Every bead ends with `Owns: <files it may write>`. Disjoint Owns sets
run concurrently; overlapping ones get a dependency edge (`bead dep add
<blocked> <blocker>`), usually by making the shared file its own bead. Before
launching: `scripts/partition-check.sh projects/<name>` must print nothing.

Bead body shape:

```
Task <id> — <title> (Phase <n>)
## Context      why; cite the plan section, decision row, or research note
## Design       approach, exact files, binding constraints
## Acceptance Criteria   each a command that passes or fails
## Notes        sequencing, gotchas (or delete)
Owns: <every file this task may write>
```

Title wording that gets executed instead of split: "Create X so that
`<command>` passes. Work on this issue directly." Body: "Do not create
sub-issues, do not split this work, and do not decompose it."

## 6. Run

`needle doctor`, then `needle run --agent claude --identifier alpha` from the
project directory; stagger launches by a second or two. Workers claim
atomically, commit with `Bead-Id: <id>` as a trailer, push, validate each
criterion, close with a reason or release with a blocker note. NEEDLE accepts a
close only if a pushed commit exists since dispatch and the gate
(`scripts/definition-of-done.sh`) passes. A worker exiting on an empty queue
is normal. Three failures quarantine a bead; do not retry forever.

Daily, two minutes: workers alive, queue draining, anything escalated. A
"starved" alarm is usually a wrong directory or a dependency cycle; run
`bead list --ready` yourself first.

## 7. Refine

Weekly: read escalations and the failure list, check the plan against what
the fleet discovered, check spend against completion. Output is an edit to
`plan.md`, which returns you to stage 3.

## Sizing

Depth (workers in one repo) is bounded by the Owns overlap ratio (under ~5%
go deep; over ~a third, re-cut) and by host memory (~500 MB per idle
supervisor plus 230–400 MB per agent; measure yours). Width (repos in flight)
is bounded only by how many have ready, reviewed work, and is where capacity
usually comes from.
