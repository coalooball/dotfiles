#!/usr/bin/env bash
set -euo pipefail

TARGET=~/.emacs.d
PULL_FILES=(
  post-early-init.el
  post-init.el
)

case "${1:-}" in
  push)
    for f in *.el; do
      [ -f "$f" ] || continue
      rsync -q "$f" "$TARGET/"
      echo "synced $f -> $TARGET/"
    done
    rm -rf "$TARGET/cyan"
    rsync -q -r cyan "$TARGET/"
    echo "synced cyan -> $TARGET/"
    ;;
  pull)
    for f in "${PULL_FILES[@]}"; do
      [ -f "$TARGET/$f" ] || continue
      rsync -q "$TARGET/$f" ./
      echo "synced $TARGET/$f -> ./"
    done
    [ -d "$TARGET/cyan" ] && { rm -rf cyan; rsync -q -r "$TARGET/cyan" ./; echo "synced $TARGET/cyan -> ./"; }
    ;;
  *)
    echo "Usage: $0 {push|pull}"
    echo "  push  - copy *.el from current dir to ~/.emacs.d/"
    echo "  pull  - copy post-early-init.el, post-init.el, cyan/ from ~/.emacs.d/ to current dir"
    exit 1
    ;;
esac
