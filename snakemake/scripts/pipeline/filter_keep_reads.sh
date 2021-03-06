#!/usr/bin/env bash

set -eu -o pipefail

SCRIPT="${1}"
CONDA_BIN="${2}"
IN_FILE_FASTQ_FWD="${3}"
IN_FILE_FASTQ_BWD="${4}"
IN_FILE_KRAKEN="${5}"
OUT_FILE_FILT_FWD="${6}"
OUT_FILE_FILT_BWD="${7}"
OUTPUT_DIR_PIPELINE="${8}"
LINEAGE_FILE="${9}"
LOG="${10}"

OUTPUT_FILES=(
  "${OUT_FILE_FILT_FWD}"
  "${OUT_FILE_FILT_BWD}"
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

check_for_reads() {
  out_file="${1}"
  if [[ ! -s "${out_file}" ]]; then
    echo "WARNING: No reads left after filtering"
    create_dummy_files
  fi
}

filter() {
  # Remove bacterial, human and fungal reads, and mitochondrial reads misclassified by kraken2
  # Creates ${SEQUENCE}_[12]_filt.fastq
  cd "${OUTPUT_DIR_PIPELINE}"
  echo "INFO: Run ${SCRIPT}"
  echo "DEBUG: ${CONDA_BIN}/python ${SCRIPT} -i ${IN_FILE_FASTQ_FWD} ${IN_FILE_FASTQ_BWD} -k ${IN_FILE_KRAKEN} \
--xT Homo,Bacteria,Fungi -x 1969841 --suffix filt --lineagefile ${LINEAGE_FILE}"

  "${CONDA_BIN}"/python "${SCRIPT}" -i "${IN_FILE_FASTQ_FWD}" "${IN_FILE_FASTQ_BWD}" -k "${IN_FILE_KRAKEN}" \
    --xT Homo,Bacteria,Fungi -x 1969841 --suffix filt --lineagefile "${LINEAGE_FILE}"

}

{
  check_infile "${IN_FILE_FASTQ_FWD}"
  filter
  retVal=$?
  check_return ${retVal}
  check_for_reads "${OUT_FILE_FILT_FWD}"
} >"${LOG}" 2>&1
