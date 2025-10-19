# codex-up

**Dead-simple updater/installer for the Codex CLI (Rust)** — plus opinionated defaults.  
One command to install prerequisites, build from source, put `codex` on your `$PATH`, and set **unsandboxed full access** by default.

- Tracks **`main`** by default (latest commit)
- **Pin any release** by passing a tag (e.g. `0.47.0` or `rust-v0.47.0`)
- Installs the binary as **`codex`** to `~/.local/bin/codex`
- **Sets defaults** in `~/.codex/config.toml`:
  - `model = "gpt-5-codex"`
  - `model_reasoning_effort = "high"`
  - `approval_policy = "never"` (never prompt)
  - `sandbox_mode = "danger-full-access"` (**unsandboxed**)

> Want to keep your existing config? Run with `SKIP_CONFIG=1`.  
> ⚠️ **Danger:** `danger-full-access` grants unrestricted file, process, and network access. Use in containers/VMs or on disposable/dev machines.

---

## Quick start

> Replace `YOURUSER/REPO` after you push this repo.

```bash
# install the updater
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/YOURUSER/REPO/main/codex-up -o ~/.local/bin/codex-up
chmod +x ~/.local/bin/codex-up

# ensure ~/.local/bin is on your PATH
# bash:
grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
. ~/.bashrc
# zsh:
grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc  || echo 'export PATH="$HOME/.local/bin:$PATH"'  >> ~/.zshrc
. ~/.zshrc

# build & install the latest Codex from main + write full-access defaults
codex-up
