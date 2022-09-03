#!/bin/bash
# Created by Sam Gleske (@samrocketman on GitHub)
# MIT licensed
# Sat Aug 27 13:35:25 EDT 2022
# Pop!_OS 18.04 LTS
# Linux 5.4.0-113-generic x86_64
# GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu)
# find (GNU findutils) 4.7.0-git
# xargs (GNU findutils) 4.7.0-git
# git version 2.17.1
#
# DESCRIPTION
#     Find images which exist in endless-sky-high-dpi but are missing from
#     endless-sky repository.
#
#     This script will exit non-zero if missing images are found.
#
# USAGE
#     git clone https://github.com/endless-sky/endless-sky-high-dpi
#     cd endless-sky-high-dpi/
#     ../find-low-dpi-images.sh

set -exo pipefail

trap '[ ! -d "${TMP_DIR:-}" ] || rm -rf "${TMP_DIR}"' EXIT
TMP_DIR="$(mktemp -d)"
export TMP_DIR


pushd "${TMP_DIR}" &> /dev/null
git clone --depth=1 https://github.com/endless-sky/endless-sky.git

# the following will exit non-zero if image not found
(
cd ~1/
find images -type f | sed 's/@2x//' | tr '\n' '\0'
) | xargs -0 -I{} -n1 -P$(nproc) -- /bin/bash -ec 'if [ -f "endless-sky/{}" ]; then exit;fi; echo "Missing endless-sky/{}"; false'
