#!/usr/bin/env bash

set -e

RAW_DATA_DIR="${1}"
CONFIG_FILE="config.yaml"
CONFIG_PREFIX_FILE="_config.yaml"
PROCESSING_DIR="$(dirname "$(dirname "$(pwd)")")"
PLATE_ID="$(basename "${PROCESSING_DIR}")"

SAMPLES_FILE="${RAW_DATA_DIR}/samples.txt"
SAMPLES_FILE_LOCAL="${PROCESSING_DIR}/samples.txt"

OUT_FILES=(
  "${CONFIG_FILE}"
  "${SAMPLES_FILE_LOCAL}"
)

usage() {
  echo "Usage: $0 RAW_DATA_DIR"
  exit 1
}

check_file_exists() {
  file="${1}"
  echo "INFO: Checking for ${file}"
  if [[ ! -f "${file}" ]]; then
    echo "ERROR: ${file} missing from current directory. Exiting..."
    exit 1
  fi
}

cleanup_out_files() {
  for file in "${OUT_FILES[@]}"; do
    rm -f "${file}"
  done
}

create_config() {
  raw_data_dir="${1}"
  cat ${CONFIG_PREFIX_FILE}
  echo ""
  echo "PLATE_ID: ${PLATE_ID}"
  echo ""
  echo "RAW_DATA_DIR: ${raw_data_dir}"
  echo ""
  echo "SAMPLES:"

  while IFS= read -r line; do
    echo "    - ${line}"
  done <"${SAMPLES_FILE}"
} >>${CONFIG_FILE}

# Checks
[[ -z ${RAW_DATA_DIR} ]] && { usage; }
check_file_exists "${SAMPLES_FILE}"

# Prepare files
cleanup_out_files
echo "INFO: Creating ${CONFIG_FILE}"
create_config "${RAW_DATA_DIR}"
echo "INFO: Copying ${SAMPLES_FILE} to ${PROCESSING_DIR}"
cp "${SAMPLES_FILE}" "${PROCESSING_DIR}"
