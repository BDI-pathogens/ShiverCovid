#!/usr/bin/env bash

set -e

IN_FILE_FASTQFWD_GZ="${1}"
IN_FILE_FASTQBWD_GZ="${2}"
OUT_FILE_FASTQFWD="${3}"
OUT_FILE_FASTQBWD="${4}"
LOG="${5}"

OUTPUT_FILES=(
  "${OUT_FILE_FASTQFWD}"
  "${OUT_FILE_FASTQBWD}"
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
  if [[ ! -s ${OUT_FILE_FASTQFWD} ]]; then
    echo "ERROR: Raw forward readfile ${OUT_FILE_FASTQFWD} is empty. Exiting..."
    exit 1
  fi
  if [[ ! -s ${OUT_FILE_FASTQBWD} ]]; then
    echo "ERROR: Raw reverse readfile ${OUT_FILE_FASTQBWD} is empty. Exiting..."
    exit 1
  fi

  read_num_fwd=$(($(wc -l <"${OUT_FILE_FASTQFWD}") / 4))
  read_num_bwd=$(($(wc -l <"${OUT_FILE_FASTQBWD}") / 4))

  if [[ ${read_num_fwd} -ne ${read_num_bwd} ]]; then
    echo "ERROR: Raw forward and reverse read numbers differ. Exiting..."
    exit 1
  fi
  echo "INFO: Raw read numbers:" ${read_num_fwd}
}

decompress() {
  echo "INFO: Merge forward fastqs and decompress"
  zcat "${IN_FILE_FASTQFWD_GZ}" >"${OUT_FILE_FASTQFWD}"

  echo "INFO: Merge reverse fastqs and decompress, while removing the 3 bases which are the SMARTer adapter"
  zcat "${IN_FILE_FASTQBWD_GZ}" | awk '{if (NR % 2 == 0) { print substr($0,4) } else { print $0 }}' >"${OUT_FILE_FASTQBWD}"
}

{
  check_infile "${IN_FILE_FASTQFWD_GZ}"
  decompress
  sanity_check
} >"${LOG}" 2>&1
