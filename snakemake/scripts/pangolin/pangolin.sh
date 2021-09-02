#!/usr/bin/env bash

set -eu -o pipefail

SCRIPT_SEQ_LEN="${1}"
CONDA_BIN="${2}"
IN_FILE="${3}"
OUT_FILE="${4}"
COVERAGE_MIN="${5}"
LOG="${6}"

check_infile() {
  in_file="${1}"
  if [[ ! -s "${in_file}" ]]; then
    echo "WARNING: ${in_file} empty"
    create_dummy_file
    exit 0
  fi
}

create_dummy_file() {
  echo "INFO: Creating dummy output file..."
  if [[ ! -f "${OUT_FILE}" ]]; then
    echo "${OUT_FILE}"
    touch "${OUT_FILE}"
  fi
}

get_seq_length() {
  seq_length=$("${CONDA_BIN}"/python "${SCRIPT_SEQ_LEN}" -1 "${IN_FILE}" | cut -d' ' -f2)
  echo "${seq_length}"
}

get_coverage() {
  in_file="${1}"
  seq_length="${2}"
  file_length=$(grep -v ">" <"${in_file}" | wc -c)
  coverage=$(echo "scale=2 ; ${seq_length} / ${file_length}" | bc)
  echo "${coverage}"
}

run_pangolin() {
  conda activate pangolin
  pangolin --outfile "${OUT_FILE}" "${IN_FILE}"
  conda deactivate
}

{
  check_infile "${IN_FILE}"
  SEQ_LENGTH=$(get_seq_length)
  COVERAGE=$(get_coverage "${IN_FILE}" "${SEQ_LENGTH}")
  echo "DEBUG: SEQ_LENGTH: ${SEQ_LENGTH}"
  echo "DEBUG: COVERAGE: ${COVERAGE}"
  if [[ "${SEQ_LENGTH}" -gt 0 ]]; then
    if (($(echo "$COVERAGE > ${COVERAGE_MIN}" | bc -l))); then
      echo "INFO: Running pangolin..."
      # shellcheck source=/dev/null
      source "$(conda info --base)/etc/profile.d/conda.sh"
      run_pangolin
    else
      echo "INFO: File does not pass coverage criteria"
      create_dummy_file
    fi
  else
    echo "INFO: Sequence length is zero"
    create_dummy_file
  fi
} >"${LOG}" 2>&1
