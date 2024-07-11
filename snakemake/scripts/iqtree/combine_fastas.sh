#!/usr/bin/env bash

set -eu -o pipefail

INPUT_DIR="${1}"
OUT_FILE="${2}"
LOG="${3}"

TEMP_OUT_FILE="${OUT_FILE}.tmp"


combine_fasta_files() {
   for file in "${INPUT_DIR}"/*.fasta; do
    if [[ -s ${file} ]]; then
      echo "INFO: Adding ${file}" >>"${LOG}"
      data=$(cat "${file}")
      echo "${data}" >>"${TEMP_OUT_FILE}"
    else
      echo "WARNING: ${file} does not exist or is empty. Skipping..." >>"${LOG}"
    fi
  done
}

{
  combine_fasta_files
  if [[ -s "${TEMP_OUT_FILE}" ]]; then
    mv "${TEMP_OUT_FILE}" "${OUT_FILE}"
  else
    touch "${OUT_FILE}"
  fi
} >"${LOG}" 2>&1
