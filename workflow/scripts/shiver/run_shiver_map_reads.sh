#!/usr/bin/env bash

set -e

SEQUENCE="${1}"
SHIVER_INITDIR="${2}"
SHIVER_CONFIG="${3}"
SHIVER_SCRIPT="${4}"
TMP_DIR_SEQUENCE="${5}"
IN_FILE_CLEAN_READS_FWD="${6}"
IN_FILE_CLEAN_READS_BWD="${7}"
IN_FILE_SHIVER_FWD="${8}"
IN_FILE_SHIVER_BWD="${9}"
OUT_FILE_BAM="${10}"
OUT_FILE_BASE_FREQS="${11}"
OUT_FILE_BASE_FREQS_GLOB="${12}"
OUT_FILE_DEDUP_STATS="${13}"
OUT_FILE_INSERT_SIZE="${14}"
OUT_FILE_PRE_DEDUP="${15}"
OUT_FILE_CONSENSUS="${16}"
OUT_FILE_CONSENSUS_GLOB="${17}"
OUT_FILE_COORDS="${18}"
OUT_FILE_REF_FASTA="${19}"
OUT_FILE_REF_FASTA_FAI="${20}"
OUT_FILE_BLAST="${21}"
OUT_FILE_SHIVER_CONTIGS="${22}"
REF_STEM_FILE="${23}"
LOG="${24}"

OUTPUT_FILES=(
  "${OUT_FILE_BAM}"
  "${OUT_FILE_BASE_FREQS}"
  "${OUT_FILE_BASE_FREQS_GLOB}"
  "${OUT_FILE_DEDUP_STATS}"
  "${OUT_FILE_INSERT_SIZE}"
  "${OUT_FILE_PRE_DEDUP}"
  "${OUT_FILE_CONSENSUS}"
  "${OUT_FILE_CONSENSUS_GLOB}"
  "${OUT_FILE_COORDS}"
  "${OUT_FILE_REF_FASTA}"
  "${OUT_FILE_REF_FASTA_FAI}"
  "${OUT_FILE_BLAST}"
  "${OUT_FILE_SHIVER_CONTIGS}"
)

delete_tmp_dir() {
  rm -rf "${TMP_DIR_SEQUENCE}"
}

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

create_tmp_dir_and_empty_files() {
  mkdir -p "${TMP_DIR_SEQUENCE}"
  cd "${TMP_DIR_SEQUENCE}"
  # tmp_blast, tmp_shiver_contigs empty because assembly not run
  touch "${OUT_FILE_BLAST}"
  touch "${OUT_FILE_SHIVER_CONTIGS}"
}

shiver_map() {
  cd "${TMP_DIR_SEQUENCE}"
  set +e
  echo "INFO: Running ${SHIVER_SCRIPT}"
  echo "DEBUG: ${SHIVER_SCRIPT} ${SHIVER_INITDIR} ${SHIVER_CONFIG} ${OUT_FILE_SHIVER_CONTIGS} ${SEQUENCE} \
${OUT_FILE_BLAST} ${REF_STEM_FILE} ${IN_FILE_SHIVER_FWD} ${IN_FILE_SHIVER_BWD} 2>&1"

  msg=$("${SHIVER_SCRIPT}" "${SHIVER_INITDIR}" "${SHIVER_CONFIG}" "${OUT_FILE_SHIVER_CONTIGS}" "${SEQUENCE}" \
    "${OUT_FILE_BLAST}" "${REF_STEM_FILE}" "${IN_FILE_SHIVER_FWD}" "${IN_FILE_SHIVER_BWD}" 2>&1)
  retVal=$?
  echo "${msg}"
  echo "INFO: ${SHIVER_SCRIPT} return value: ${retVal}"
  set -e

  if [[ ${retVal} -ne 0 ]]; then
    if [[ ${retVal} -eq 3 ]]; then
      create_dummy_files
    else
      echo "ERROR: ${SHIVER_SCRIPT} failed. Exiting..."
      exit ${retVal}
    fi
  fi

}

{
  check_infile "${IN_FILE_CLEAN_READS_FWD}" # Processing should not continue if empty
  check_infile "${IN_FILE_CLEAN_READS_BWD}" # Processing should not continue if empty
  check_infile "${IN_FILE_SHIVER_FWD}"
  check_infile "${IN_FILE_SHIVER_BWD}"
  delete_tmp_dir
  create_tmp_dir_and_empty_files
  shiver_map
} >"${LOG}" 2>&1
