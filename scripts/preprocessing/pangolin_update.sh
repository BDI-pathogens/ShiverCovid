#!/usr/bin/env bash

set -eu -o pipefail

update_pangolin() {
  echo "INFO: Running pangolin update..."
  pangolin --update
}

function error() {
  if [[ "$1" -ne 0 ]]; then
    msg="ERROR: Error '$1' occurred executing $0"
    echo "${msg}"
    exit 1
  fi
}

{
  trap 'error $?' EXIT
  # shellcheck source=/dev/null
  source "$(conda info --base)/etc/profile.d/conda.sh"
  conda activate pangolin
  update_pangolin
  conda deactivate
}
