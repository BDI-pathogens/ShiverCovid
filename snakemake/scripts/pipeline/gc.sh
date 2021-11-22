#!/usr/bin/env bash

set -eu -o pipefail

SCRIPT="${1}"
CONDA_BIN="${2}"
IN_FILE_RAWFASTQ_FWD="${3}"
OUT_FILE_GC="${4}"
LOG="${5}"

OUTPUT_FILES=(
  "${OUT_FILE_GC}"
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

check_return() {
  retVal="${1}"
  echo "INFO: ${SCRIPT} return value: ${retVal}"
  if [[ "${retVal}" -ne 0 ]]; then
    echo "ERROR: ${SCRIPT} failed. Exiting..."
    exit "${retVal}"
  fi
}

gc() {
  echo "INFO: Run ${SCRIPT}"
  echo "DEBUG: ${CONDA_BIN}/python ${SCRIPT} ${IN_FILE_RAWFASTQ_FWD} 1>${OUT_FILE_GC} 2>>${LOG}"

  "${CONDA_BIN}"/python "${SCRIPT}" "${IN_FILE_RAWFASTQ_FWD}" 1>"${OUT_FILE_GC}" 2>>"${LOG}"
}

{
  check_infile "${IN_FILE_RAWFASTQ_FWD}"
  gc
  retVal=$?
  check_return ${retVal}
} >"${LOG}" 2>&1
