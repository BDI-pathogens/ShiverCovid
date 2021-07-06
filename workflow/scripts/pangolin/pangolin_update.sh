#!/usr/bin/env bash

set -eu -o pipefail

OUT_FILE_FLAG="${1}"
LOG="${2}"

update_pangolin() {
  set +e
  pangolin --update
  # shellcheck disable=SC2181
  while [ $? -ne 0 ]; do
    pangolin --update
  done
  set -e
}

{
  # shellcheck source=/dev/null
  source "$(conda info --base)/etc/profile.d/conda.sh"
  conda activate pangolin
  update_pangolin
  conda deactivate
  touch "${OUT_FILE_FLAG}"
} >"${LOG}" 2>&1
