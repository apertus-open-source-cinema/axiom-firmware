#!/bin/bash
# This script wraps patch, so that it can be executed multiple times without causing any harm
# stolen from https://stackoverflow.com/questions/21928344/how-to-not-break-the-makefile-if-patch-skips-the-patch

set -xeuo pipefail

# If we could reverse the patch, then it has already been applied; skip it
if cat ${*:2} | patch -d $1 -p1 --dry-run --reverse --force >/dev/null 2>&1; then
  # patch already applied - skipping
  true
else 
  # patch not yet applied
  cat ${*:2} | patch -d $1 -p1 -Ns || (echo "Patch failed" >&2 && exit 1)
fi
