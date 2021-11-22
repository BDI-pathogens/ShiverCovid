#!/bin/bash

set -e

RAW_DATA_DIR="${1}"
SMARTER_ADAPTER_KIT="${2}"
REPO_BASE_DIR="$(dirname "$(dirname "$(dirname "$(readlink -f -- "$0")")")")"

SCRIPT_UPDATE_PANGOLIN="${REPO_BASE_DIR}/scripts/preprocessing/pangolin_update.sh"

usage() {
  echo "Usage: $0 RAW_DATA_DIR SMARTER_ADAPTER_KIT"
  echo "* RAW_DATA_DIR: The directory containing the raw data"
  echo "* SMARTER_ADAPTER_KIT: The SMARTer Adapter kit used by the lab [v2, v3]"
  exit 1
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

[[ -z ${RAW_DATA_DIR} || -z ${SMARTER_ADAPTER_KIT} ]] && { usage; }
{
  trap 'error $?' EXIT
  msg="INFO: Raw Data Directory: ${RAW_DATA_DIR}"
  echo "${msg}"
  msg="INFO: SMARTer Adapter Kit: ${SMARTER_ADAPTER_KIT}"
  echo "${msg}"
  msg="INFO: Preparing Snakemake config for processing"
  echo "${msg}"
  cd "${REPO_BASE_DIR}/snakemake"
  ./prepare.sh "${RAW_DATA_DIR}" "${SMARTER_ADAPTER_KIT}"
  update_pangolin
}
