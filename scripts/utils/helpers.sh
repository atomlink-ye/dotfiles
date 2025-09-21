#!/bin/bash

# Common utility functions shared by chezmoi provisioning scripts.

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
