#!/usr/bin/env bash

set -eu -o pipefail

CONDA_BIN="${1}"
IN_FILE_FASTQ_FWD="${2}"
IN_FILE_FASTQ_BWD="${3}"
OUT_FILE_KRAKEN="${4}"
OUT_FILE_KRAKEN_REPORT="${5}"
KRAKEN2_DB="${6}"
LOG="${7}"
CORES="${8}"

OUTPUT_FILES=(
  "${OUT_FILE_KRAKEN}"
  "${OUT_FILE_KRAKEN_REPORT}"
)

READNUM=$(($(wc -l <"${IN_FILE_FASTQ_FWD}") / 4))

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
  echo "INFO: kraken2 return value: ${retVal}"
  if [[ "${retVal}" -ne 0 ]]; then
    echo "ERROR: kraken2 failed. Exiting..."
    exit "${retVal}"
  fi
}

sanity_check() {
  echo "INFO: Sanity check"
  if [[ "${READNUM}" -ne $(($(wc -l <"${OUT_FILE_KRAKEN}"))) ]]; then
    echo "ERROR: Read numbers differ with kraken output. Truncated file? Exiting..."
    exit 1
  fi
}

kraken2() {
  echo "INFO: Run kraken2"
  echo "DEBUG: ${CONDA_BIN}/kraken2 --report ${OUT_FILE_KRAKEN_REPORT} --db ${KRAKEN2_DB} --paired \
    --threads ${CORES} ${IN_FILE_FASTQ_FWD} ${IN_FILE_FASTQ_BWD} 1>${OUT_FILE_KRAKEN} 2>>${LOG}"

  "${CONDA_BIN}"/kraken2 --report "${OUT_FILE_KRAKEN_REPORT}" --db "${KRAKEN2_DB}" --paired \
    --threads "${CORES}" "${IN_FILE_FASTQ_FWD}" "${IN_FILE_FASTQ_BWD}" 1>"${OUT_FILE_KRAKEN}" 2>>"${LOG}"
}

{
  check_infile "${IN_FILE_FASTQ_FWD}"
  kraken2
  retVal=$?
  check_return ${retVal}
  sanity_check
} >"${LOG}" 2>&1
