#!/usr/bin/env bash

set -eu -o pipefail

IN_FILE_GZ_FWD="${1}"
IN_FILE_GZ_BWD="${2}"
OUT_FILE_FWD="${3}"
OUT_FILE_BWD="${4}"
LOG="${5}"
SMARTER_ADAPTER_KIT="${6}"

OUTPUT_FILES=(
  "${OUT_FILE_FWD}"
  "${OUT_FILE_BWD}"
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

sanity_check() {
  echo "INFO: Sanity check"
  # Sanity check - verify that both files contain same number of reads and there are no blank lines
  if [[ ! -s ${OUT_FILE_FWD} ]]; then
    echo "ERROR: Raw forward readfile ${OUT_FILE_FWD} is empty. Exiting..."
    exit 1
  fi
  if [[ ! -s ${OUT_FILE_BWD} ]]; then
    echo "ERROR: Raw reverse readfile ${OUT_FILE_BWD} is empty. Exiting..."
    exit 1
  fi

  read_num_fwd=$(($(wc -l <"${OUT_FILE_FWD}") / 4))
  read_num_bwd=$(($(wc -l <"${OUT_FILE_BWD}") / 4))

  if [[ ${read_num_fwd} -ne ${read_num_bwd} ]]; then
    echo "ERROR: Raw forward and reverse read numbers differ. Exiting..."
    exit 1
  fi
  echo "INFO: Raw read numbers:" ${read_num_fwd}
}

decompress_fwd() {
  echo "INFO: Merge forward fastqs and decompress"
  zcat "${IN_FILE_GZ_FWD}" >"${OUT_FILE_FWD}"
}

decompress_and_trim_bwd() {
  if [[ "${SMARTER_ADAPTER_KIT}" == "v2" ]]; then
    echo "INFO: Decompress reverse fastq, while removing 3 bases (the v2 SMARTer adapter)"
    zcat "${IN_FILE_GZ_BWD}" | awk '{if (NR % 2 == 0) { print substr($0,4) } else { print $0 }}' >"${OUT_FILE_BWD}"
  elif [[ "${SMARTER_ADAPTER_KIT}" == "v3" ]]; then
    echo "INFO: Decompress reverse fastq, while removing 14 bases (the v3 SMARTer adapter)"
    zcat "${IN_FILE_GZ_BWD}" | awk '{if (NR % 2 == 0) { print substr($0,15) } else { print $0 }}' >"${OUT_FILE_BWD}"
  else
    echo "ERROR: Unknown SMARTer Adapter kit '${SMARTER_ADAPTER_KIT}'. Exiting..."
    exit 1
  fi
}

{
  check_infile "${IN_FILE_GZ_FWD}"
  decompress_fwd
  decompress_and_trim_bwd
  sanity_check
} >"${LOG}" 2>&1
