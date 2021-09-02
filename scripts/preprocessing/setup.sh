#!/bin/bash

set -e

RAW_DATA_DIR="${1}"
REPO_BASE_DIR="$(dirname "$(dirname "$(dirname "$(readlink -f -- "$0")")")")"

SCRIPT_UPDATE_PANGOLIN="${REPO_BASE_DIR}/scripts/preprocessing/pangolin_update.sh"

check_input() {
  if [[ -z "${RAW_DATA_DIR}" ]]; then
    echo "Usage: $0 <Raw Data Directory>"
  fi
}

update_pangolin() {
  "${SCRIPT_UPDATE_PANGOLIN}"
  retVal=$?
  if [[ "${retVal}" -ne 0 ]]; then
    msg="ERROR: Failed to update pangolin. Exiting..."
    echo "${msg}"
    exit 1
  fi
}

function error() {
  if [[ "$1" -ne 0 ]]; then
    msg="ERROR: Error '$1' occurred executing $0"
    echo "${msg}"
    exit 1
  fi
}

check_input
{
  trap 'error $?' EXIT
  msg="INFO: Raw Data Directory: ${RAW_DATA_DIR}"
  echo "${msg}"
  msg="INFO: Preparing Snakemake config for processing"
  echo "${msg}"
  cd "${REPO_BASE_DIR}/snakemake"
  ./prepare.sh "${RAW_DATA_DIR}"
  update_pangolin
}
