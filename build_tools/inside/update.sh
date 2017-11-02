#!/bin/bash
set -e 
set -o pipefail
cd /opt/beta-software

# pull newest code from git
git pull

# do the real update
build_tools/inside/update_inner.sh