# public-devpod

A DevPod workspace shell for building **public** projects with agent fleets. This
repository holds only the container definition, the tool bootstrap, a project
template, and short standing rules. The projects themselves live under
`projects/`, each as its own independent public GitHub repository; that
directory is gitignored here and reconstructed from `projects.txt`.

The method every project follows is the seven-stage workflow manual
(https://jedarden.com/guides/workflow/), condensed in `docs/notes/workflow.md`:
scaffold docs-first, research, one plan file, review it, decompose into beads
with declared file ownership, run NEEDLE workers, refine.

## Use

```bash
devpod up github.com/jarvis-labs-ai/public-devpod --id public-devpod --ide none
devpod ssh public-devpod                       # or: ssh public-devpod.devpod
scripts/new-project.sh <name> -d "what it is"  # scaffold + create public repo + push
scripts/clone-projects.sh                      # re-clone everything after a recreate
```

Tools installed by `.devcontainer/install-tools.sh`: tmux, gh, Claude Code,
ccusage, NEEDLE + `bead` (tracker), and the claude-interactive plugin. Run
`gh auth login` once per container (or pass `GH_TOKEN` via
`devpod up --workspace-env`); nothing is stored in this repo.

## Layout

| Path | What |
| --- | --- |
| `.devcontainer/` | Image, features, and the bootstrap script |
| `config/needle-host.yaml` | Seed for `~/.config/needle/config.yaml` (copied only if absent) |
| `templates/project/` | The docs-first scaffold `new-project.sh` copies |
| `scripts/` | `new-project.sh`, `clone-projects.sh`, `partition-check.sh` |
| `projects/` | Public sub-repos (gitignored); manifest in `projects.txt` |
| `docs/notes/workflow.md` | The seven stages and their gates, condensed |
