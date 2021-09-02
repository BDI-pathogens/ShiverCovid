#!/usr/bin/env bash

set -eu -o pipefail

SCRIPT="${1}"
CONDA_BIN="${2}"
IN_FILE="${3}"
OUT_FILE="${4}"
LOG="${5}"

OUTPUT_FILES=(
  "${OUT_FILE}"
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

check_out_file() {
  out_file="${1}"
  if [[ ! -s "${out_file}" ]]; then
    echo "ERROR: ${out_file} empty. Exiting..."
    exit 1
  fi
}

preprocess_bwd() {
  echo "INFO: Run ${SCRIPT} for ${IN_FILE}"
  # Map up to 10 million (pre-filtered) read pairs to avoid extreme runtimes (take first 40mln lines)
  echo "DEBUG: ${CONDA_BIN}/python ${SCRIPT} ${IN_FILE} 2 | head -n 40000000 1>${OUT_FILE} 2>>${LOG}"

  "${CONDA_BIN}"/python "${SCRIPT}" "${IN_FILE}" 2 | head -n 40000000 1>"${OUT_FILE}" 2>>"${LOG}"
}

{
  check_infile "${IN_FILE}"
  preprocess_bwd
  retVal=$?
  check_return ${retVal}
  check_out_file "${OUT_FILE}"
} >"${LOG}" 2>&1
