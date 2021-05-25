#!/usr/bin/env bash

set -e

CONDA_BIN="${1}"
IN_FILE_COMBINED_FASTAS="${2}"
OUT_FILE_CONTREE="${3}"
OUT_FILE_IQTREE="${4}"
OUT_FILE_MLDIST="${5}"
OUT_FILE_SPLITS="${6}"
OUT_FILE_TREEFILE="${7}"
MAX_CORES="${8}"
SUBSTITUTION_MODEL="${9}"
BOOTSTRAP_REPLICATES="${10}"
LOG="${11}"

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
  msg=$("${CONDA_BIN}"/iqtree -s "${IN_FILE_COMBINED_FASTAS}" -nt AUTO -ntmax "${MAX_CORES}" -m "${SUBSTITUTION_MODEL}" \
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
