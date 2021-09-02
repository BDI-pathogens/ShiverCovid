#!/usr/bin/env bash

set -eu -o pipefail

OUT_FILE_FLAG="${1}"
LOG="${2}"

update_pangolin() {
  set +e
  msg=$(pangolin --update)
  retVal=$?
  set -e
  echo "${msg}"

  echo "INFO: Pangolin update return value: ${retVal}"
  if [[ ${retVal} -ne 0 ]]; then
    echo "INFO: Pangolin update unsuccessful. Retrying..."
    set +e
    msg=$(pangolin --update)
    retVal=$?
    set -e
    echo "${msg}"
    if [[ ${retVal} -ne 0 ]]; then
      echo "ERROR: Pangolin update retry failed. Exiting..."
      exit ${retVal}
    else
      echo "INFO: Pangolin update retry return value: ${retVal}"
    fi
  fi
}

{
  # shellcheck source=/dev/null
  source "$(conda info --base)/etc/profile.d/conda.sh"
  conda activate pangolin
  update_pangolin
  conda deactivate
  touch "${OUT_FILE_FLAG}"
} >"${LOG}" 2>&1
