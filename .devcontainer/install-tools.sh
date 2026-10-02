[ -f "$HOME/.tmux.conf" ] || ln -sf "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then git clone -q https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" >/dev/null 2>&1 && "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || true; fi
ok "tmux.conf linked; tpm $( [ -d "$HOME/.tmux/plugins/tpm" ] && echo installed || echo missing )"#!/usr/bin/env bash
# postCreateCommand for public-devpod. Runs once per container build (and again
# after `devpod up --recreate`, because the container home is reset then).
# Idempotent and best-effort: a failing step is reported, not fatal.
set -u
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT="$REPO_DIR/.devcontainer/installation-report.md"
export PATH="$HOME/.local/bin:$PATH"
SUDO=""; if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" -ne 0 ]; then SUDO=sudo; fi

step() { printf '\n==> %s\n' "$*"; }
ok()   { printf -- '- OK   %s\n' "$*" >> "$REPORT"; }
fail() { printf -- '- FAIL %s\n' "$*" >> "$REPORT"; }
printf '# public-devpod installation report\n\nGenerated %s\n\n' "$(date -u +%FT%TZ)" > "$REPORT"

step "git configuration"
git config --global --add safe.directory '*' || true
git config --global init.defaultBranch main || true
git config --global pull.rebase false || true
# Identity: DevPod forwards the host's git user/email when it can. Otherwise pass
# GIT_USER_NAME / GIT_USER_EMAIL with `devpod up --workspace-env`. Nothing is hardcoded.
if [ -z "$(git config --global user.name || true)" ] && [ -n "${GIT_USER_NAME:-}" ]; then git config --global user.name "$GIT_USER_NAME"; fi
if [ -z "$(git config --global user.email || true)" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then git config --global user.email "$GIT_USER_EMAIL"; fi
if [ -n "$(git config --global user.email || true)" ]; then ok "git identity: $(git config --global user.name) <$(git config --global user.email)>"; else fail "git identity not set (run: git config --global user.name/user.email)"; fi

step "apt packages"
if $SUDO apt-get update -qq && $SUDO apt-get install -y -qq tmux sqlite3 jq ripgrep curl ca-certificates >/dev/null; then ok "apt: tmux sqlite3 jq ripgrep"; else fail "apt packages"; fi

step "PATH"
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  grep -qs 'HOME/.local/bin' "$rc" || printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$rc"
done
mkdir -p "$HOME/.local/bin"

step "Claude Code"
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1 || npm install -g @anthropic-ai/claude-code >/dev/null 2>&1 || $SUDO npm install -g @anthropic-ai/claude-code >/dev/null 2>&1 || true
fi
if command -v claude >/dev/null 2>&1; then ok "claude: $(claude --version 2>/dev/null | head -1)"; else fail "claude (install: curl -fsSL https://claude.ai/install.sh | bash)"; fi

step "ccusage"
if ! command -v ccusage >/dev/null 2>&1; then npm install -g ccusage >/dev/null 2>&1 || $SUDO npm install -g ccusage >/dev/null 2>&1 || true; fi
if command -v ccusage >/dev/null 2>&1; then ok "ccusage"; else fail "ccusage (npm install -g ccusage)"; fi

step "NEEDLE + bead (fleet orchestrator and tracker)"
# Prebuilt Linux x86_64 binaries, checksum-verified, into ~/.local/bin. Installs needle,
# needle-transform-*, and the bead-rs backend `bead`.
if ! command -v needle >/dev/null 2>&1 || ! command -v bead >/dev/null 2>&1; then
  curl -fsSL https://github.com/jedarden/NEEDLE/releases/latest/download/install.sh | bash >/dev/null 2>&1 || true
fi
if command -v needle >/dev/null 2>&1; then ok "needle: $(needle --version 2>/dev/null | head -1)"; else fail "needle (curl -fsSL https://github.com/jedarden/NEEDLE/releases/latest/download/install.sh | bash)"; fi
if command -v bead >/dev/null 2>&1; then ok "bead: $(bead --version 2>/dev/null | head -1)"; else fail "bead (same installer as needle)"; fi

step "claude-interactive plugin (runs workers under the Claude subscription instead of API billing)"
if ! command -v claude-interactive >/dev/null 2>&1 && command -v gh >/dev/null 2>&1; then
  tmp="$(mktemp -d)"
  if (cd "$tmp" && gh release download --repo jedarden/NEEDLE --pattern 'claude-interactive*' >/dev/null 2>&1 && chmod +x claude-interactive-install.sh && ./claude-interactive-install.sh >/dev/null 2>&1); then :; fi
  rm -rf "$tmp"
fi
if command -v claude-interactive >/dev/null 2>&1; then ok "claude-interactive"; else fail "claude-interactive (optional; see README)"; fi

step "NEEDLE host config"
mkdir -p "$HOME/.config/needle"
if [ ! -f "$HOME/.config/needle/config.yaml" ]; then
  cp "$REPO_DIR/config/needle-host.yaml" "$HOME/.config/needle/config.yaml" && ok "seeded ~/.config/needle/config.yaml from config/needle-host.yaml"
else
  ok "kept existing ~/.config/needle/config.yaml (never overwritten)"
fi

step "tmux"
[ -f "$HOME/.tmux.conf" ] || ln -sf "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
ok "tmux.conf linked"

step "clone public projects from projects.txt"
if bash "$REPO_DIR/scripts/clone-projects.sh"; then ok "projects cloned (see projects/)"; else fail "clone-projects.sh"; fi

step "done"
printf '\nTool versions:\n' >> "$REPORT"
for t in git gh node python3 docker tmux claude needle bead; do
  if command -v "$t" >/dev/null 2>&1; then printf -- '- %s: %s\n' "$t" "$("$t" --version 2>/dev/null | head -1)" >> "$REPORT"; fi
done
cat "$REPORT"
