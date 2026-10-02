# AGENTS.md

Standing rules for this repository. It is a workspace shell, not a project: the
projects live in `projects/<name>`, each its own public git repository with its
own `AGENTS.md` and `docs/plan/plan.md`. Work on a project from inside its
directory, under its rules.

## Build and test

- This repo has no build. Check scripts with: `bash -n scripts/*.sh .devcontainer/install-tools.sh`

## Commits

- Style: `type(scope): summary` (`feat`, `fix`, `chore`, `docs`).
- Never force-push.
- Never commit anything under `projects/` other than `projects/README.md`; sub-projects are separate repositories.
- Never commit secrets, tokens, or `.env` files. This repository is public; a leaked credential is a failed task.

## Projects

- Create a project only with `scripts/new-project.sh <name>`; it scaffolds the docs-first tree, the tracker, and the public GitHub repo, and registers the repo in `projects.txt`.
- Every project is public by default. Use `--private` only when explicitly told to.

## When blocked

Stop. Say what is missing. Do not improvise around a blocker, and do not resolve conflicting instructions yourself; surface them.
