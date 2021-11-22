#!/usr/bin/env bash

set -e

RAW_DATA_DIR="${1}"
SMARTER_ADAPTER_KIT="${2}"
CONFIG_FILE="config.yaml"
CONFIG_PREFIX_FILE="_config.yaml"
PROCESSING_DIR="$(dirname "$(dirname "$(pwd)")")"
PLATE_ID="$(basename "${PROCESSING_DIR}")"

SAMPLES_FILE="${PROCESSING_DIR}/samples.txt"

OUT_FILES=(
  "${CONFIG_FILE}"
)

usage() {
  echo "Usage: $0 RAW_DATA_DIR SMARTER_ADAPTER_KIT"
  echo "* RAW_DATA_DIR: The directory containing the raw data"
  echo "* SMARTER_ADAPTER_KIT: The SMARTer Adapter kit used by the lab [v2, v3]"
  exit 1
}

check_file_exists() {
  file="${1}"
  echo "INFO: Checking for ${file}"
  if [[ ! -f "${file}" ]]; then
    echo "ERROR: ${file} missing. Exiting..."
    exit 1
  fi
}

cleanup_out_files() {
  for file in "${OUT_FILES[@]}"; do
    rm -f "${file}"
  done
}

create_config() {
  cat ${CONFIG_PREFIX_FILE}
  echo ""
  echo "PLATE_ID: ${PLATE_ID}"
  echo ""
  echo "RAW_DATA_DIR: ${RAW_DATA_DIR}"
  echo ""
  echo "SMARTER_ADAPTER_KIT: ${SMARTER_ADAPTER_KIT}"
  echo ""
  echo "SAMPLES:"

  while IFS= read -r line; do
    if [[ -n ${line} ]]; then
      echo "    - ${line}"
    fi
  done <"${SAMPLES_FILE}"
} >>${CONFIG_FILE}

# Checks
[[ -z ${RAW_DATA_DIR} || -z ${SMARTER_ADAPTER_KIT} ]] && { usage; }
check_file_exists "${SAMPLES_FILE}"

# Prepare files
cleanup_out_files
echo "INFO: Creating ${CONFIG_FILE}"
create_config
