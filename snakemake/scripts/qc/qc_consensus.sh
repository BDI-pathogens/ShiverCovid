#!/usr/bin/env bash

set -eu -o pipefail

SCRIPT_IZ="${1}"
SCRIPT_SEQ_LEN="${2}"
SMARTER_ADAPTER_KIT="${3}"
SHIVER_MAPPER="${4}"
SEQUENCE="${5}"
PROCESSING_DIR="${6}"
CONDA_BIN="${7}"
IN_FILE_RAWFASTQFWD="${8}"
IN_FILE_GC_FILE="${9}"
IN_FILE_KRAKEN_REPORT="${10}"
IN_FILE_BAM="${11}"
IN_FILE_PREDEPUP_BAM="${12}"
IN_FILE_INSERT_SIZE_FILE="${13}"
IN_FILE_DEDUP_STATS="${14}"
IN_FILE_CONSENSUS_RAW="${15}"
IN_FILE_CONSENSUS_BASEFREQS_RUN1="${16}"
IN_FILE_CONSENSUS_BASEFREQS_RUN2="${17}"
IN_FILE_VL="${18}"
OUT_FILE="${19}"
LOG="${20}"

REF_NAME="NC_045512.2"

qc() {
  get_meta_data
  get_vl
  get_bestref
  get_insert_stats
  get_gc
  get_nreads
  get_nhuman_reads
  get_ncov_reads
  get_mapped_prededup
  get_mapped
  get_mapped_positive
  get_duprate
  get_lengths_raw
  get_lengths_basefreq
} 2>>"${LOG}"

get_meta_data() {
  echo "INFO: Get metadata" >>"${LOG}"
  plate_id="$(basename "${PROCESSING_DIR}")"
  smarter_adapter_kit="${SMARTER_ADAPTER_KIT}"
  mapper="${SHIVER_MAPPER}"
  samplename="$(cut -d'_' -f1 <<<"${SEQUENCE}")"
  treatment="$(cut -d'_' -f2 <<<"${SEQUENCE}")"
  echo -n "${plate_id},${smarter_adapter_kit},${mapper},${SEQUENCE},${samplename},${treatment}," >>"${OUT_FILE}"
  echo "DEBUG: ${plate_id},${smarter_adapter_kit},${mapper},${SEQUENCE},${samplename},${treatment}," >>"${LOG}"
}

get_vl() {
  echo "INFO: Get vl" >>"${LOG}"
  if [[ -s ${IN_FILE_VL} ]]; then
    vl=$(grep -E -m1 "^${SEQUENCE}" "${IN_FILE_VL}" | awk '{print $NF}')
  else
    vl=""
  fi
  echo -n "${vl}," >>"${OUT_FILE}"
  echo "DEBUG: ${vl}," >>"${LOG}"
}

get_bestref() {
  echo "INFO: Get bestref" >>"${LOG}"
  echo -n "${REF_NAME}," >>"${OUT_FILE}"
  echo "DEBUG: ${REF_NAME}," >>"${LOG}"
}

get_insert_stats() {
  echo "INFO: Get insert stats" >>"${LOG}"
  if [[ -s ${IN_FILE_INSERT_SIZE_FILE} ]]; then
    iz=$("${CONDA_BIN}"/python "${SCRIPT_IZ}" "${IN_FILE_INSERT_SIZE_FILE}")
    retVal=$?
    if [[ ${retVal} -ne 0 ]]; then
      echo "ERROR: Command failed. Exiting..." >>"${LOG}"
      echo "${iz}" >>"${LOG}"
      exit ${retVal}
    fi
  else
    iz=',,,,'
  fi
  echo -n "${iz}," >>"${OUT_FILE}"
  echo "DEBUG: ${iz}," >>"${LOG}"
}

get_gc() {
  echo "INFO: Get gc" >>"${LOG}"
  gc=$(awk '{print $NF}' <"${IN_FILE_GC_FILE}")
  echo -n "${gc}," >>"${OUT_FILE}"
  echo "DEBUG: ${gc}," >>"${LOG}"
}

get_nreads() {
  echo "INFO: Get number of reads" >>"${LOG}"
  # Raw read pairs = classified + unclassified reads from kraken report (Taxid 0 and 1)
  nraw=$(head -n2 "${IN_FILE_KRAKEN_REPORT}" | awk '($5<=1) { sum += $2 } END {print sum}')
  if [[ -z ${nraw} ]]; then
    nraw=$(($(wc -l <"${IN_FILE_RAWFASTQFWD}") / 4))
    nraw=${nraw%.}
  fi
  echo -n "${nraw}," >>"${OUT_FILE}"
  echo "DEBUG: ${nraw}," >>"${LOG}"
}

get_nhuman_reads() {
  echo "INFO: Get number of human reads" >>"${LOG}"
  nhuman=$(grep -m1 'Homo sapiens' "${IN_FILE_KRAKEN_REPORT}" | cut -f2)
  echo -n "${nhuman}," >>"${OUT_FILE}"
  echo "DEBUG: ${nhuman}," >>"${LOG}"
}

get_ncov_reads() {
  echo "INFO: Get number of coronavirus reads" >>"${LOG}"
  # Number of Coronavirus reads = number of classified reads using Kraken, RefSeq(Coronavirus)
  ncov=$(awk '($5==11118) { print $2 }' "${IN_FILE_KRAKEN_REPORT}")
  echo -n "${ncov}," >>"${OUT_FILE}"
  echo "DEBUG: ${ncov}," >>"${LOG}"
}

get_mapped_prededup() {
  echo "INFO: Get mapped prededup" >>"${LOG}"
  mapped_prededup=$("${CONDA_BIN}"/samtools flagstat "${IN_FILE_PREDEPUP_BAM}" | grep read1 | cut -d' ' -f1)
  echo -n "${mapped_prededup}," >>"${OUT_FILE}"
  echo "DEBUG: ${mapped_prededup}," >>"${LOG}"
}

get_mapped() {
  echo "INFO: Get mapped" >>"${LOG}"
  mapped=$("${CONDA_BIN}"/samtools flagstat "${IN_FILE_BAM}" | grep read1 | cut -d' ' -f1)
  echo -n "${mapped}," >>"${OUT_FILE}"
  echo "DEBUG: ${mapped}," >>"${LOG}"
}

get_mapped_positive() {
  echo "INFO: Get mapped_positive" >>"${LOG}"
  mapped_positive=$(($(samtools view -f3 "${IN_FILE_BAM}" | awk '($2!=147)&&($2!=99)' | wc -l) / 2))
  echo -n "${mapped_positive}," >>"${OUT_FILE}"
  echo "DEBUG: ${mapped_positive}," >>"${LOG}"
}

get_duprate() {
  echo "INFO: Get duprate" >>"${LOG}"
  duprate=$(grep -h -m1 ^"Unknown Library" "${IN_FILE_DEDUP_STATS}" | cut -f9)
  echo -n "${duprate}," >>"${OUT_FILE}"
  echo "DEBUG: ${duprate}," >>"${LOG}"
}

get_lengths_raw() {
  echo "INFO: Get lengths for raw shiver data" >>"${LOG}"
  length_raw1=$("${CONDA_BIN}"/python "${SCRIPT_SEQ_LEN}" -1 "${IN_FILE_CONSENSUS_RAW}" | cut -d' ' -f2)
  lenght_raw2=$("${CONDA_BIN}"/python "${SCRIPT_SEQ_LEN}" -1 -C "${IN_FILE_CONSENSUS_RAW}" | cut -d' ' -f2)
  lengths_raw=${length_raw1},${lenght_raw2}
  echo -n "${lengths_raw}," >>"${OUT_FILE}"
  echo "DEBUG: ${lengths_raw}," >>"${LOG}"
}

# Ensure the last field has no comma at the end
get_lengths_basefreq() {
  echo "INFO: Get lengths for basefreq data" >>"${LOG}"
  length_base1_run1=$("${CONDA_BIN}"/python "${SCRIPT_SEQ_LEN}" --ignore-n "${IN_FILE_CONSENSUS_BASEFREQS_RUN1}" | cut -d' ' -f2)
  length_base2_run1=$("${CONDA_BIN}"/python "${SCRIPT_SEQ_LEN}" --ignore-n -C "${IN_FILE_CONSENSUS_BASEFREQS_RUN1}" | cut -d' ' -f2)
  length_base1_run2=$("${CONDA_BIN}"/python "${SCRIPT_SEQ_LEN}" --ignore-n "${IN_FILE_CONSENSUS_BASEFREQS_RUN2}" | cut -d' ' -f2)
  length_base2_run2=$("${CONDA_BIN}"/python "${SCRIPT_SEQ_LEN}" --ignore-n -C "${IN_FILE_CONSENSUS_BASEFREQS_RUN2}" | cut -d' ' -f2)
  lengths_base=${length_base1_run1},${length_base2_run1},${length_base1_run2},${length_base2_run2}
  echo -n "${lengths_base}" >>"${OUT_FILE}"
  echo "DEBUG: ${lengths_base}" >>"${LOG}"
}

{
  qc
} >"${LOG}" 2>&1
