#!/usr/bin/env bash

set -eu -o pipefail

CONDA_BIN="${1}"
IN_FILE_FILT_FWD="${2}"
IN_FILE_FILT_BWD="${3}"
OUT_FILE_CLEAN_FWD="${4}"
OUT_FILE_CLEAN_BWD="${5}"
TMP_OUT_FILE_FQ_FWD="${6}"
TMP_OUT_FILE_FQ_BWD="${7}"
ADAPTERS_FILE="${8}"
TRIMMOMATIC_MINLEN="${9}"
LOG="${10}"
CORES="${11}"

OUTPUT_FILES=(
  "${OUT_FILE_CLEAN_FWD}"
  "${OUT_FILE_CLEAN_BWD}"
  "${TMP_OUT_FILE_FQ_FWD}"
  "${TMP_OUT_FILE_FQ_BWD}"
)

check_infile() {
  in_file="${1}"
  if [[ ! -s "${in_file}" ]]; then
    echo "WARNING: ${in_file} empty"
    create_dummy_files
    exit 0
  fi
}

create_dummy_files() {
  echo "INFO: Creating dummy output files..."
  for file in "${OUTPUT_FILES[@]}"; do
    if [[ ! -f "${file}" ]]; then
      echo "${file}"
      touch "${file}"
    fi
  done
}

run_trimmomatic() {
  echo "INFO: Running trimmomatic"
  set +e
  "${CONDA_BIN}"/trimmomatic PE -threads "${CORES}" \
    "${IN_FILE_FILT_FWD}" "${IN_FILE_FILT_BWD}" \
    "${OUT_FILE_CLEAN_FWD}" "${TMP_OUT_FILE_FQ_FWD}" \
    "${OUT_FILE_CLEAN_BWD}" "${TMP_OUT_FILE_FQ_BWD}" \
    ILLUMINACLIP:"${ADAPTERS_FILE}":2:10:7:1:true MINLEN:"${TRIMMOMATIC_MINLEN}" LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20
  retVal=$?
  echo "INFO: trimmomatic return value: ${retVal}"
  set -e
  if [[ ${retVal} -ne 0 ]]; then
    error_check=$(grep "Error: Unable to detect quality encoding" "${LOG}")
    if [[ -n ${error_check} ]]; then
      create_dummy_files
    else
      echo "ERROR: trimmomatic failed. Exiting..."
      exit ${retVal}
    fi
  fi
}

{
  check_infile "${IN_FILE_FILT_FWD}"
  run_trimmomatic
} >"${LOG}" 2>&1
