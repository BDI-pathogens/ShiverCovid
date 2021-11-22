#!/usr/bin/env bash

set -eu -o pipefail

CONDA_BIN="${1}"
OUT_FILE="${2}"
LOG="${2}"

{
  REPO="$("${CONDA_BIN}"/git remote get-url origin)"
  BRANCH="$("${CONDA_BIN}"/git rev-parse --abbrev-ref HEAD)"
  RELEASE="$("${CONDA_BIN}"/git describe --tags --always)"
  COMMIT_HASH="$("${CONDA_BIN}"/git rev-parse HEAD)"

  echo "REPO: ${REPO}"
  echo "BRANCH: ${BRANCH}"
  echo "RELEASE: ${RELEASE}"
  echo "COMMIT_HASH: ${COMMIT_HASH}"
} 1>"${OUT_FILE}" 2>>"${LOG}"
