#!/bin/bash
set -euo pipefail

# shellcheck source=utils/helpers.sh
source "${CHEZMOI_WORKING_TREE}/scripts/utils/helpers.sh"

CURRENT_USER="$(id -un)"
SUDO=""
as_root || SUDO="sudo"

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

# ---------- Set fish as default shell (if available) ----------
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