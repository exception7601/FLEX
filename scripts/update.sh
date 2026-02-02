#!/bin/sh

set -e

./scripts/update-submodule.sh

if git diff --quiet FLEX; then
  echo "FLEX no update. No update needed."
  exit 0
fi

./scripts/create-xcframeworks.sh
