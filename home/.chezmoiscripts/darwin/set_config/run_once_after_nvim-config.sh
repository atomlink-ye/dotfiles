#!/bin/bash
set -euo pipefail

# shellcheck source=utils/helpers.sh
source "${CHEZMOI_WORKING_TREE}/scripts/utils/helpers.sh"

# ---------- Neovim config ----------
log "Setting up Neovim config…"

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

log "Neovim config setup done ✅"