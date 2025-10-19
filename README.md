# codex-up

Build and install Codex from `main` with a preconfigured local setup.  
A small installer for the Codex CLI (Rust). It installs prerequisites, builds from the tip of **`main`**, adds `codex` to your `$PATH`, and can write a permissive local config (no approval prompts, unsandboxed).

Upstream (original repo): https://github.com/openai/codex

- Tracks **`main`** by default (tip-of-`main`)  
- **Pin any release** with a tag (e.g. `0.47.0` or `rust-v0.47.0`)  
- Always available as **`codex`** (installed to `~/.local/bin/codex`)  
- Works on **macOS** and **Linux**; auto-installs `git`, `curl`, **Rust**, and `ripgrep` if missing  
- Defaults to a permissive, unsandboxed mode (changeable; see “Defaults”).

## What This Is

- Simple, auditable wrapper to build and install the upstream OpenAI Codex CLI from source.
- Tracks `main` by default (tip-of-`main`); supports pinning to tagged releases.
- Offers optional permissive defaults for local development (unsandboxed, no approval prompts).
- Not a fork, not a replacement UI — just an installer and config bootstrap.

## Who This Is For

- Builders who want the current Codex CLI from `main` quickly.
- Power users comfortable with unsandboxed, no-approval workflows.
- Researchers, plugin/tool authors, and maintainers testing against `main` or specific tags.
- Teams using ephemeral/dev machines where a fast, reproducible setup is useful.

## What To Know

- Upstream lives at `openai/codex` (linked above); this project is unaffiliated and focuses solely on build/setup.
- Defaults are permissive: `approval_policy = "never"`, `sandbox_mode = "danger-full-access"` (change these if you need guardrails).
- Installs `codex` to `~/.local/bin/codex` and clones the source to `~/src/openai-codex` by default.
- macOS and Linux supported; common package managers auto-detected for prerequisites.

## Quick start

Install from this repo:

```bash
# install the updater
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/hweihwang/codex-up/main/codex-up -o ~/.local/bin/codex-up
chmod +x ~/.local/bin/codex-up

# ensure ~/.local/bin is on your PATH (bash example)
grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
. ~/.bashrc

# build & install Codex from main (tip-of-main) + write permissive defaults
codex-up
```

## Usage

```bash
codex-up               # build from main (tip-of-main)
codex-up main          # same as above
codex-up 0.47.0        # build a specific release (auto-normalizes to rust-v0.47.0)
codex-up rust-v0.47.0  # explicit tag

# verify
codex --version
which -a codex
```

**Upgrade:** just run `codex-up` again.  
**Switch versions:** run `codex-up <tag>` (e.g. `0.47.0`), then `codex-up main` to go back.

## What it does

- Checks/installs prerequisites: `git`, `curl`, `ripgrep`, **Rust (rustup)**  
- Clones or updates `https://github.com/openai/codex` to `~/src/openai-codex`  
- Builds the Rust CLI from `codex-rs/` with `cargo build --release`  
- Installs the binary to `~/.local/bin/codex`  
- **Writes a pre-configured full-access config** to `~/.codex/config.toml` (backs up any existing file)

> Package managers supported for deps (best-effort): `brew`, `apt-get`, `dnf`, `pacman`. If none are available, the script prints what to install manually.

## Defaults

The script writes this to `~/.codex/config.toml`:

```toml
model = "gpt-5-codex"
model_reasoning_effort = "high"
approval_policy = "never"
sandbox_mode = "danger-full-access"

[notice]
hide_full_access_warning = true
```

Summary: model as below, high reasoning, no approval prompts, unsandboxed full access, and the UI warning is hidden.  
Don’t like these defaults? Edit the file or run with `SKIP_CONFIG=1` to preserve your own.

## Customize (optional)

Environment variables:

- `REPO_DIR` — where to keep the clone (default: `~/src/openai-codex`)  
- `BIN_DIR` — where to install the `codex` binary (default: `~/.local/bin`)  
- `CONFIG_DIR` — where to write config (default: `~/.codex`)  
- `SKIP_CONFIG=1` — skip creating/updating `config.toml`

Examples:

```bash
REPO_DIR=$HOME/dev/codex-src codex-up
BIN_DIR=/usr/local/bin sudo -E codex-up
SKIP_CONFIG=1 codex-up 0.47.0
```

## Troubleshooting

**`codex: command not found`** — Ensure `~/.local/bin` is on your `$PATH` and re-open your shell.  
**Wrong `codex` picked when you also used Homebrew or npm** — Put `~/.local/bin` before other paths:

```bash
which -a codex
hash -r   # clear shell command cache
```

**macOS toolchain issues** — Install Xcode Command Line Tools once:

```bash
xcode-select --install
```

## Uninstall

```bash
rm -f ~/.local/bin/codex ~/.local/bin/codex-up
rm -rf ~/src/openai-codex
# Optional: restore your previous config backup in ~/.codex/
```

## Security notes (please read)

If you keep the defaults, `danger-full-access` means unrestricted file, process, and network access with no prompts. Prefer using this on disposable/dev machines, VMs, or containers. If you need guardrails, change to:

```toml
approval_policy = "on-request"
sandbox_mode = "workspace-write"  # or "read-only"
```
