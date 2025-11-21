# codex-up

Build and install the OpenAI Codex CLI from `openai/codex` (tip of `main` or any tag). Leaves your `~/.codex/config.toml` alone.

## Quick install

```bash
npm i -g codex-up   # or: npx codex-up
codex-up            # build tip of main
codex-up 0.47.0     # pinned release (normalizes to rust-v0.47.0)
codex-up <git-ref>  # any branch/tag/SHA
codex --version
```

## What it does

- Installs deps if missing: git, curl, ripgrep, rustup (macOS + Linux).
- Clones/updates `https://github.com/openai/codex` in `~/src/openai-codex`.
- Builds `codex-rs` with `cargo build --release`; installs to `~/.local/bin/codex`.
- Leaves `~/.codex/config.toml` untouched; configure Codex yourself.

## Options

- Env vars: `REPO_DIR`, `BIN_DIR`.
- Re-run `codex-up` to upgrade or switch versions.
- GitHub releases also ship a DotSlash file named `codex`.

## Requirements

- macOS 12+ or Linux (Ubuntu 20.04+/Debian 10+, Windows 11 via WSL2).
- Node.js 14+ only for the npm install path.
- PATH should include `~/.local/bin` and your npm global bin; 4-GB+ RAM recommended.

## Troubleshooting

- `codex` missing: ensure `~/.local/bin` is on PATH; restart shell.
- Picking another `codex`: put `~/.local/bin` first; `which -a codex`.
- macOS build issues: `xcode-select --install`.

## Uninstall

```bash
npm uninstall -g codex-up
rm -f ~/.local/bin/codex ~/.local/bin/codex-up
rm -rf ~/src/openai-codex
```

## Security

codex-up does not write configs. Set `~/.codex/config.toml` to whatever guardrails you want, e.g.:

```toml
approval_policy = "on-request"
sandbox_mode = "workspace-write"
```
