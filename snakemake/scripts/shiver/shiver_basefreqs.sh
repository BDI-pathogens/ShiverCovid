#!/usr/bin/env bash

set -e

SCRIPT_ANALYSE_PILEUP="${1}"
SCRIPT_CALL_CONSENSUS="${2}"
IN_FILE_BAM_PRE_DEDUP="${3}"
OUT_FILE_BASEFREQS="${4}"
OUT_FILE_CONSENSUS_RUN1="${5}"
OUT_FILE_CONSENSUS_RUN2="${6}"
TMP_OUT_FILE_PILEUP="${7}"
REF_STEM_FILE="${8}"
MINCOV_RELAXED_RUN1="${9}"
MINCOV_STRICT_RUN1="${10}"
MINCOV_RELAXED_RUN2="${11}"
MINCOV_STRICT_RUN2="${12}"
MIN_BASE_QUALITY="${13}"
MAX_DEPTH="${14}"
LOG="${15}"

CONSENSUS_SEQ_NAME_RUN1=$(basename "${OUT_FILE_CONSENSUS_RUN1}" | cut -d. -f1)
CONSENSUS_SEQ_NAME_RUN2=$(basename "${OUT_FILE_CONSENSUS_RUN2}" | cut -d. -f1)

OUTPUT_FILES=(
  "${OUT_FILE_BASEFREQS}"
  "${OUT_FILE_CONSENSUS_RUN1}"
  "${OUT_FILE_CONSENSUS_RUN2}"
)

check_return() {
  retVal="${1}"
  script="${2}"
  echo "INFO: ${script} return value: ${retVal}"
  if [[ "${retVal}" -ne 0 ]]; then
    echo "ERROR: ${script} failed. Exiting..."
    exit "${retVal}"
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

check_for_pileup() {
  if [[ ! -s "${TMP_OUT_FILE_PILEUP}" ]]; then
    echo "WARNING: Found no pileup information"
    create_dummy_files
    exit 0
  fi
}

samtools_pileup() {
  echo "INFO: Run samtools mpileup"
  echo "DEBUG: samtools mpileup --no-BAQ --min-BQ ${MIN_BASE_QUALITY} --max-depth ${MAX_DEPTH} \
    --reference ${REF_STEM_FILE} ${IN_FILE_BAM_PRE_DEDUP} 1>${TMP_OUT_FILE_PILEUP} 2>>${LOG}"

  samtools mpileup --no-BAQ --min-BQ "${MIN_BASE_QUALITY}" --max-depth "${MAX_DEPTH}" \
    --reference "${REF_STEM_FILE}" "${IN_FILE_BAM_PRE_DEDUP}" 1>"${TMP_OUT_FILE_PILEUP}" 2>>"${LOG}"
  retVal=$?
  check_return ${retVal} "samtools mpileup"
}

analyse_pileup() {
  echo "INFO: Create BaseFreq files from pre-deduplicated data"
  echo "DEBUG: ${SCRIPT_ANALYSE_PILEUP} ${TMP_OUT_FILE_PILEUP} ${REF_STEM_FILE} 1>${OUT_FILE_BASEFREQS} 2>>${LOG}"
  ${SCRIPT_ANALYSE_PILEUP} "${TMP_OUT_FILE_PILEUP}" "${REF_STEM_FILE}" 1>"${OUT_FILE_BASEFREQS}" 2>>"${LOG}"

  retVal=$?
  check_return ${retVal} "${SCRIPT_ANALYSE_PILEUP}"
}

call_consensus_run1() {
  echo "INFO: Call consensus from pre-deduplicated data - run1"
  echo "DEBUG: ${SCRIPT_CALL_CONSENSUS} --skip-ref-in-output --use-n-for-missing -C ${CONSENSUS_SEQ_NAME_RUN1} \
${OUT_FILE_BASEFREQS} ${MINCOV_RELAXED_RUN1} ${MINCOV_STRICT_RUN1} -1 1>${OUT_FILE_CONSENSUS_RUN1} 2>>${LOG}"

  "${SCRIPT_CALL_CONSENSUS}" --skip-ref-in-output --use-n-for-missing -C "${CONSENSUS_SEQ_NAME_RUN1}" \
    "${OUT_FILE_BASEFREQS}" "${MINCOV_RELAXED_RUN1}" "${MINCOV_STRICT_RUN1}" -1 1>"${OUT_FILE_CONSENSUS_RUN1}" 2>>"${LOG}"
  retVal=$?
  check_return ${retVal} "${SCRIPT_CALL_CONSENSUS}"
}

call_consensus_run2() {
  echo "INFO: Call consensus from pre-deduplicated data - run2"
  echo "DEBUG: ${SCRIPT_CALL_CONSENSUS} --skip-ref-in-output --use-n-for-missing -C ${CONSENSUS_SEQ_NAME_RUN2} \
${OUT_FILE_BASEFREQS} ${MINCOV_RELAXED_RUN2} ${MINCOV_STRICT_RUN2} -1 1>${OUT_FILE_CONSENSUS_RUN2} 2>>${LOG}"

  "${SCRIPT_CALL_CONSENSUS}" --skip-ref-in-output --use-n-for-missing -C "${CONSENSUS_SEQ_NAME_RUN2}" \
    "${OUT_FILE_BASEFREQS}" "${MINCOV_RELAXED_RUN2}" "${MINCOV_STRICT_RUN2}" -1 1>"${OUT_FILE_CONSENSUS_RUN2}" 2>>"${LOG}"
  retVal=$?
  check_return ${retVal} "${SCRIPT_CALL_CONSENSUS}"
}

{
  samtools_pileup
  check_for_pileup
  analyse_pileup
  call_consensus_run1
  call_consensus_run2
} >"${LOG}" 2>&1
