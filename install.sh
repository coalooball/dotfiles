#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MIRROR="${EMACS_MIRROR:-https://ghproxy.net/https://github.com/jamescherti/minimal-emacs.d.git}"
EMACS_DIR="${HOME}/.emacs.d"
BRANCH="main"

link() {
  local src="$DOTFILES/$1"
  local dest="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    printf 'error: missing source %s\n' "$src" >&2
    return 1
  fi

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    local backup
    backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    printf 'backup %s -> %s\n' "$dest" "$backup"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  printf 'link   %s -> %s\n' "$dest" "$src"
}

sync_emacs() {
  if [[ -d "$EMACS_DIR/.git" ]]; then
    printf 'pull   %s\n' "$EMACS_DIR"
    git -C "$EMACS_DIR" remote set-url origin "$MIRROR"
    git -C "$EMACS_DIR" fetch --depth=1 origin "$BRANCH"
    git -C "$EMACS_DIR" reset --hard FETCH_HEAD
    return
  fi

  if [[ -e "$EMACS_DIR" ]]; then
    shopt -s dotglob nullglob
    local entries=("$EMACS_DIR"/*)
    shopt -u dotglob nullglob
    if (( ${#entries[@]} > 0 )); then
      printf 'error: %s exists and is not a git repository\n' "$EMACS_DIR" >&2
      return 1
    fi
  fi

  printf 'clone  %s\n' "$MIRROR"
  git clone --depth=1 "$MIRROR" "$EMACS_DIR"
}

sync_emacs

link .emacs.d/post-init.el       .emacs.d/post-init.el
link .emacs.d/post-early-init.el .emacs.d/post-early-init.el
link .emacs.d/cyan               .emacs.d/cyan
