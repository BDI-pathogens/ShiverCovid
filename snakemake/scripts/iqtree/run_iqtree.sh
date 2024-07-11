#!/usr/bin/env bash

set -eu -o pipefail

IN_FILE_COMBINED_FASTAS="${1}"
OUT_FILE_CONTREE="${2}"
OUT_FILE_IQTREE="${3}"
OUT_FILE_MLDIST="${4}"
OUT_FILE_SPLITS="${5}"
OUT_FILE_TREEFILE="${6}"
MAX_CORES="${7}"
SUBSTITUTION_MODEL="${8}"
BOOTSTRAP_REPLICATES="${9}"
LOG="${10}"

OUTPUT_FILES=(
  "${OUT_FILE_CONTREE}"
  "${OUT_FILE_IQTREE}"
  "${OUT_FILE_MLDIST}"
  "${OUT_FILE_SPLITS}"
  "${OUT_FILE_TREEFILE}"
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

run_iqtree() {
  set +e
  msg=$(iqtree -s "${IN_FILE_COMBINED_FASTAS}" -nt AUTO -ntmax "${MAX_CORES}" -m "${SUBSTITUTION_MODEL}" \
    -czb -bb "${BOOTSTRAP_REPLICATES}")
  retVal=$?
  echo "${msg}"
  echo "INFO: iqtree return value: ${retVal}"
  set -e
  if [[ ${retVal} -ne 0 ]]; then
    if [[ ${retVal} -eq 2 ]]; then # It makes no sense to perform bootstrap with less than x sequences.
      create_dummy_files
    else
      echo "ERROR: iqtree failed. Exiting..."
      exit ${retVal}
    fi
  fi
}

{
  run_iqtree
} >"${LOG}" 2>&1
