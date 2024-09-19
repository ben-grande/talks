#!/bin/sh
set -eu

## Also install python3-mistune0 if not installing recommendations.
if ! command -v lookatme >/dev/null; then
  echo "Missing dependency: lookatme" >&2
  exit 1
fi

lookatme --live --safe --theme dark README.md
