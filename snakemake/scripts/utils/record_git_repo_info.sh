#!/usr/bin/env bash

set -eu -o pipefail

OUT_FILE="${1}"
LOG="${2}"

{
  REPO="$(git remote get-url origin)"
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  RELEASE="$(git describe --tags --always)"
  COMMIT_HASH="$(git rev-parse HEAD)"

  echo "REPO: ${REPO}"
  echo "BRANCH: ${BRANCH}"
  echo "RELEASE: ${RELEASE}"
  echo "COMMIT_HASH: ${COMMIT_HASH}"
} 1>"${OUT_FILE}" 2>>"${LOG}"
