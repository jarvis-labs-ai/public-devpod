# projects/

Every directory here is an independent **public** git repository, cloned from
`projects.txt` by `scripts/clone-projects.sh`. This directory is gitignored by
the parent repo, so nothing in it is ever committed to `public-devpod`.

- Add a new project: `scripts/new-project.sh <name>` (scaffolds the docs-first
  tree, initialises the bead tracker, creates the public GitHub repo, pushes).
- Re-clone everything on a fresh container: `scripts/clone-projects.sh`.
