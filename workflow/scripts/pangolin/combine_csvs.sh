#!/usr/bin/env bash

set -eu -o pipefail

OUT_FILE="${1}"
OUTPUT_DIR_PANGOLIN="${2}"
PANGOLIN_FILE_SUFFIX="${3}"
LOG="${4}"

TEMP_OUT_FILE="${OUT_FILE}.tmp"

header() {
  for file in "${OUTPUT_DIR_PANGOLIN}"/*"${PANGOLIN_FILE_SUFFIX}"*; do
    if [[ -s "${file}" ]]; then
      header=$(head -1 "${file}")
      break
    fi
  done
  echo "${header}"
} >"${TEMP_OUT_FILE}"

combine_csvs() {
  header
  for file in "${OUTPUT_DIR_PANGOLIN}"/*"${PANGOLIN_FILE_SUFFIX}"*; do
    if [[ -s ${file} ]]; then
      echo "INFO: Adding ${file}" >>"${LOG}"
      data=$(awk NR\>1 "${file}")
      echo "${data}" >>"${TEMP_OUT_FILE}"
    else
      echo "WARNING: ${file} does not exist or is empty. Skipping..." >>"${LOG}"
    fi
  done
}

sort_tmp_csv() {
  head -n 1 "${TEMP_OUT_FILE}" >"${TEMP_OUT_FILE}.sort" && tail -n +2 "${TEMP_OUT_FILE}" | sort -t "|" -k 2 >>"${TEMP_OUT_FILE}.sort"
  mv "${TEMP_OUT_FILE}.sort" "${TEMP_OUT_FILE}"
}

{
  combine_csvs
  sort_tmp_csv
  mv "${TEMP_OUT_FILE}" "${OUT_FILE}"
} >"${LOG}" 2>&1
