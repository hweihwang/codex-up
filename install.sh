#!/usr/bin/env bash
set -euo pipefail

# codex-up ,  build/install Codex CLI from source
# Usage:
#   codex-up              # build from main (tip-of-main)
#   codex-up main         # same as above
#   codex-up 0.47.0       # build a specific release (auto-normalizes to rust-v0.47.0)
#   codex-up rust-v0.47.0 # explicit tag
# First run copies this helper to $BIN_DIR (default ~/.local/bin) so codex-up is available anywhere.
#
# Env:
#   REPO_DIR    (default: $HOME/Projects/openai-codex)
#   BIN_DIR     (default: $HOME/.local/bin)

TARGET="${1:-main}"

REPO_URL="https://github.com/openai/codex"
REPO_DIR="${REPO_DIR:-$HOME/Projects/openai-codex}"
BUILD_DIR="$REPO_DIR/codex-rs"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
SCRIPT_NAME="codex-up"
SCRIPT_TARGET="$BIN_DIR/$SCRIPT_NAME"
SCRIPT_SOURCE="${BASH_SOURCE[0]:-$0}"
if [ "${SCRIPT_SOURCE#/}" = "$SCRIPT_SOURCE" ]; then
  SCRIPT_SOURCE="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)/$(basename "$SCRIPT_SOURCE")"
fi

have() { command -v "$1" >/dev/null 2>&1; }

pm_install() {
  if   have brew;    then brew install "$@"
  elif have apt-get; then sudo apt-get update && sudo apt-get install -y "$@"
  elif have dnf;     then sudo dnf install -y "$@"
  elif have pacman;  then sudo pacman -S --noconfirm "$@"
  else
    echo ">> No supported package manager found; please install: $*"
  fi
}

echo ">> Checking prerequisites (git, curl, ripgrep, Rust)..."
have git  || pm_install git
have curl || pm_install curl
have rg   || pm_install ripgrep

if ! have cargo; then
  echo ">> Installing Rust toolchain (rustup)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # shellcheck disable=SC1091
  . "$HOME/.cargo/env"
  rustup component add rustfmt
  rustup component add clippy
fi

mkdir -p "$BIN_DIR" "$(dirname "$REPO_DIR")"

if [ -f "$SCRIPT_SOURCE" ] && [ "$SCRIPT_SOURCE" != "$SCRIPT_TARGET" ]; then
  if install -m 0755 "$SCRIPT_SOURCE" "$SCRIPT_TARGET"; then
    echo ">> Installed codex-up helper to $SCRIPT_TARGET"
  else
    echo ">> Warning: unable to install codex-up helper to $SCRIPT_TARGET (continuing)" >&2
  fi
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  echo ">> Cloning $REPO_URL to $REPO_DIR"
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo ">> Using existing repo at $REPO_DIR"
fi

echo ">> Fetching updates..."
git -C "$REPO_DIR" fetch --tags --prune

if [ "$TARGET" = "main" ]; then
  git -C "$REPO_DIR" checkout -q main
  git -C "$REPO_DIR" pull --ff-only
else
  # Normalize "0.47.0" -> "rust-v0.47.0"
  if [[ "$TARGET" =~ ^[0-9]+(\.[0-9]+)*(-.*)?$ ]]; then
    TARGET="rust-v$TARGET"
  fi
  echo ">> Checking out $TARGET"
  git -C "$REPO_DIR" checkout -q "$TARGET"
fi

echo ">> Building Codex (release mode)..."
cd "$BUILD_DIR"
cargo build --release

echo ">> Installing binary to $BIN_DIR/codex"
install -m 0755 "target/release/codex" "$BIN_DIR/codex"

# PATH hint
SHELL_NAME="${SHELL##*/}"
SHELL_NAME="${SHELL_NAME:-sh}"
if ! echo ":$PATH:" | grep -q ":$BIN_DIR:"; then
  echo ">> Heads up: add $BIN_DIR to your PATH:"
  case "$SHELL_NAME" in
    zsh)
      echo "   echo 'export PATH=\"$BIN_DIR:\\$PATH\"' >> ~/.zprofile"
      echo "   source ~/.zprofile"
      ;;
    bash)
      echo "   echo 'export PATH=\"$BIN_DIR:\\$PATH\"' >> ~/.bashrc"
      echo "   source ~/.bashrc"
      ;;
    fish)
      echo "   set -U fish_user_paths $BIN_DIR \\$fish_user_paths"
      ;;
    *)
      echo "   export PATH=\"$BIN_DIR:\\$PATH\""
      ;;
  esac
fi

echo ">> Done. codex at: $(command -v codex || echo "$BIN_DIR/codex")"
codex --version || true
