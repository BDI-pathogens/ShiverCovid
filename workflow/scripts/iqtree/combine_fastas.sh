#!/usr/bin/env bash

set -eu -o pipefail

OUT_FILE="${1}"
LOG="${2}"
FILE_ARRAY_START_POSITION=3
INPUT_ARRAY=("$@")

TEMP_OUT_FILE="${OUT_FILE}.tmp"

combine_csvs() {
  for file in "${INPUT_ARRAY[@]:${FILE_ARRAY_START_POSITION}-1}"; do
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
  combine_csvs
  if [[ -s "${TEMP_OUT_FILE}" ]]; then
    mv "${TEMP_OUT_FILE}" "${OUT_FILE}"
  else
    touch "${OUT_FILE}"
  fi
} >"${LOG}" 2>&1
