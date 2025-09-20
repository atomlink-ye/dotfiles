#!/usr/bin/env bash
set -euo pipefail

# ---------- helpers ----------
log()   { printf "\033[1;32m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()   { printf "\033[1;31m[ERR]\033[0m  %s\n" "$*" >&2; }
have()  { command -v "$1" >/dev/null 2>&1; }
as_root(){ [ "$(id -u)" -eq 0 ]; }
ensure_line_in_file() {
  # $1=file, $2=line
  local file="$1" line="$2"
  grep -qxF -- "$line" "$file" 2>/dev/null || printf "%s\n" "$line" >>"$file"
}

CURRENT_USER="$(id -un)"
SUDO=""
as_root || SUDO="sudo"

# ---------- 1) Homebrew ----------
if ! have brew; then
  log "Installing Homebrew (non-interactive)…"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  log "Homebrew already installed."
fi

# ---------- Ensure brew shellenv is loaded (macOS & Linux) ----------
if command -v brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  BREW_SHELLENV_LINE="eval \"\$(${HOMEBREW_PREFIX}/bin/brew shellenv)\""

  ensure_line_in_file "$HOME/.bashrc"   "$BREW_SHELLENV_LINE"
  ensure_line_in_file "$HOME/.config/fish/config.fish"   "$BREW_SHELLENV_LINE"

  eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
  log "Configured Homebrew shellenv (prefix: $HOMEBREW_PREFIX)."
else
  warn "brew not found in PATH; skipping shellenv configuration."
fi
# ---------- 2) Brew bundle ----------
if [ -f "$HOME/.brewfile" ]; then
  log "Installing formulas from ~/.brewfile via brew bundle…"
  brew bundle --file="$HOME/.brewfile"
else
  warn "~/.brewfile not found; skipping brew bundle."
fi

# ---------- 3) Neovim config ----------
NVIM_DIR="$HOME/.config/nvim"
REPO_URL="https://github.com/atomsi7/kickstart.nvim.git"
mkdir -p "$(dirname "$NVIM_DIR")"

if [ -d "$NVIM_DIR/.git" ]; then
  log "nvim config repo already present; pulling latest…"
  git -C "$NVIM_DIR" pull --ff-only || warn "git pull failed (non-fast-forward or network?)."
elif [ -d "$NVIM_DIR" ] && [ -n "$(ls -A "$NVIM_DIR" 2>/dev/null || true)" ]; then
  warn "$NVIM_DIR exists and isn't a git repo; leaving as-is."
else
  log "Cloning nvim config…"
  git clone "$REPO_URL" "$NVIM_DIR"
fi

# Copy unsynced.lua if example exists and target missing
EXAMPLE_UNSYNCED="$NVIM_DIR/lua/custom/unsynced.lua.example"
TARGET_UNSYNCED="$NVIM_DIR/lua/custom/unsynced.lua"
if [ -f "$EXAMPLE_UNSYNCED" ] && [ ! -f "$TARGET_UNSYNCED" ]; then
  log "Creating custom/unsynced.lua from example…"
  cp "$EXAMPLE_UNSYNCED" "$TARGET_UNSYNCED"
else
  [ -f "$TARGET_UNSYNCED" ] && log "custom/unsynced.lua already exists; leaving it."
fi

# ---------- 4) Set fish as default shell (if available) ----------
FISH_PATH="$(command -v fish || true)"
if [ -n "$FISH_PATH" ]; then
  if ! grep -qxF "$FISH_PATH" /etc/shells 2>/dev/null; then
    log "Adding $FISH_PATH to /etc/shells…"
    printf "%s\n" "$FISH_PATH" | $SUDO tee -a /etc/shells >/dev/null
  fi

  # Change default shell only if needed
  CURRENT_SHELL="${SHELL:-}"
  if [ "$CURRENT_SHELL" != "$FISH_PATH" ]; then
    log "Changing default shell to fish for user $CURRENT_USER…"
    if as_root; then
      chsh -s "$FISH_PATH" "$CURRENT_USER" || warn "chsh failed."
    else
      $SUDO chsh -s "$FISH_PATH" "$CURRENT_USER" || warn "chsh failed (need password?)."
    fi
  else
    log "fish is already the default shell."
  fi
else
  warn "fish not found in PATH; skip changing default shell. (Install it via brew or your package manager.)"
fi

log "All done ✅"
