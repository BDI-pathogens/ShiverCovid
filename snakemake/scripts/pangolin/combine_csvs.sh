#!/usr/bin/env bash

set -eu -o pipefail

OUT_FILE="${1}"
OUTPUT_DIR_PANGOLIN="${2}"
PANGOLIN_FILE_SUFFIX="${3}"
LOG="${4}"

TEMP_OUT_FILE="${OUT_FILE}.tmp"

OUTPUT_FILES=(
  "${OUT_FILE}"
)

create_dummy_files() {
  echo "INFO: Creating dummy output files..."
  for file in "${OUTPUT_FILES[@]}"; do
    if [[ ! -f "${file}" ]]; then
      echo "${file}"
      touch "${file}"
    fi
  done
} >>"${LOG}"

get_header() {
  for file in "${OUTPUT_DIR_PANGOLIN}"/*"${PANGOLIN_FILE_SUFFIX}"*; do
    if [[ -s "${file}" ]]; then
      header=$(head -1 "${file}")
      echo "${header}"
      break
    fi
  done
}

combine_csvs() {
  header=$(get_header)
  if [[ -z "${header}" ]]; then
    echo "WARNING: All input files are empty"
    create_dummy_files
  else
    echo "${header}" >>"${TEMP_OUT_FILE}"
    for file in "${OUTPUT_DIR_PANGOLIN}"/*"${PANGOLIN_FILE_SUFFIX}"*; do
      if [[ -s ${file} ]]; then
        echo "INFO: Adding ${file}" >>"${LOG}"
        data=$(awk NR\>1 "${file}")
        echo "${data}" >>"${TEMP_OUT_FILE}"
      else
        echo "WARNING: ${file} does not exist or is empty. Skipping..." >>"${LOG}"
      fi
    done
  fi
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
