#!/bin/bash
# Created by Sam Gleske (@samrocketman on GitHub)
# GPLv3 licensed
# Sat Aug 27 13:35:25 EDT 2022
#
# DESCRIPTION
#     Find images which exist in endless-sky-high-dpi but are missing from
#     endless-sky repository.
#
#     This script will exit non-zero if missing images are found.
#
# USAGE
#     Stand alone
#         git clone https://github.com/endless-sky/endless-sky-high-dpi
#         cd endless-sky-high-dpi/
#         ./scripts/find-low-dpi-images.sh
#
#     Using an already cloned repository.
#         ./scripts/find-low-dpi-images.sh ~/git/endless-sky/

set -exo pipefail

trap '[ ! -d "${TMP_DIR:-}" ] || rm -rf "${TMP_DIR}"' EXIT
TMP_DIR="$(mktemp -d)"
export TMP_DIR

function canonicalize() (
  cd "$1"
  echo "$PWD"
)

export hidpi_assets es_repo
hidpi_assets="${PWD}"
if [ -n "${1:-}" ] && [ -d "${1%/}/.git" ]; then
  es_repo="$(canonicalize "${1}")"
fi

if [ -z "${es_repo:-}" ]; then
  pushd "${TMP_DIR}" &> /dev/null
  git clone --depth=1 https://github.com/endless-sky/endless-sky.git
  es_repo="$(canonicalize "./endless-sky")"
  popd &> /dev/null
fi

if [ "${hidpi_assets}" = "${es_repo}" ]; then
  echo 'High DPI repo cannot test against itself.' >&2
  exit 1
fi

# the following will exit non-zero if image not found
(
  cd "${hidpi_assets}"
  find images -type f | sed 's/@2x//' | tr '\n' '\0'
) | xargs -0 -I{} -n1 -P"$(nproc)" -- /bin/bash -ec 'test -f "'"${es_repo}"'/{}" || ( echo "Missing endless-sky/{}"; false )'
