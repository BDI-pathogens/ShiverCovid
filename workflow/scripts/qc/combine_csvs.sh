#!/usr/bin/env bash

set -e

OUT_FILE="${1}"
RAW_MINCOV_RELAXED="${2}"
RAW_MINCOV_STRICT="${3}"
BASEFREQS_MINCOV_RELAXED_RUN1="${4}"
BASEFREQS_MINCOV_STRICT_RUN1="${5}"
BASEFREQS_MINCOV_RELAXED_RUN2="${6}"
BASEFREQS_MINCOV_STRICT_RUN2="${7}"
LOG="${8}"
FILE_ARRAY_START_POSITION=9
INPUT_ARRAY=("$@")

TEMP_OUT_FILE="${OUT_FILE}.tmp"

header() {
  echo "plateid,\
seqname,\
samplename,\
treatment,\
vl,\
bestref,\
insertsize_05,\
insertsize_median,\
insertsize_95,\
insertnum350,\
insertfrac350,\
gc,\
readnum,\
readnum_human,\
readnum_coronavirus,\
mapped_prededup,\
mapped,\
mapped_positive,\
dup,\
mincov${RAW_MINCOV_RELAXED},\
mincov${RAW_MINCOV_STRICT},\
dup_mincov${BASEFREQS_MINCOV_RELAXED_RUN1},\
dup_mincov${BASEFREQS_MINCOV_STRICT_RUN1},\
dup_mincov${BASEFREQS_MINCOV_RELAXED_RUN2},\
dup_mincov${BASEFREQS_MINCOV_STRICT_RUN2}"
} >"${TEMP_OUT_FILE}"

combine_csvs() {
  header
  for file in "${INPUT_ARRAY[@]:${FILE_ARRAY_START_POSITION}-1}"; do
    if [[ -s ${file} ]]; then
      echo "INFO: Adding ${file}" >>"${LOG}"
      data=$(cat "${file}")
      echo "${data}" >>"${TEMP_OUT_FILE}"
    else
      echo "WARNING: ${file} does not exist or is empty. Skipping..." >>"${LOG}"
    fi
  done
}

sort_tmp_csv() {
  head -n 1 "${TEMP_OUT_FILE}" >"${TEMP_OUT_FILE}.sort" && tail -n +2 "${TEMP_OUT_FILE}" | sort -t "|" -k 2 >>"${TEMP_OUT_FILE}.sort"
  mv "${TEMP_OUT_FILE}.sort" "${TEMP_OUT_FILE}"
}

{
  combine_csvs
  sort_tmp_csv
  mv "${TEMP_OUT_FILE}" "${OUT_FILE}"
} >"${LOG}" 2>&1
