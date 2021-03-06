#!/bin/bash

set -e

SCRIPT_DIR="$(pwd)"
PARENT_PARENT_DIR=$(dirname "$(dirname "$(pwd)")")
PLATE_ID="$(basename "${PARENT_PARENT_DIR}")"

check_file_exists() {
  file="${1}"
  echo "INFO: Checking for ${file}"
  if [[ ! -f "${file}" ]]; then
    echo "ERROR: ${file} missing from current directory. Exiting..."
    exit 1
  fi
}

run() {
  "$(which snakemake)" \
    --cluster "$(which qsub) -cwd -P {params.project} -q {params.queues} -pe shmem {params.cores} -o /dev/null -j y -v PATH={params.conda_bin}:$PATH -S /bin/bash" \
    --jobs 50 \
    --jn "{rulename}_${PLATE_ID}.{jobid}.sh" \
    --use-conda \
    --configfile "${CONFIG}" \
    --output-wait 30 \
    --max-status-checks-per-second 0.01 \
    --rerun-incomplete \
    --keep-going
}

export SGE_ROOT="${SGE_ROOT}"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}"/argparse.sh || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('-c', '--config', default="config.yaml", type=str,
                    help='name of config file [default %(default)s]')
EOF
check_file_exists "${CONFIG}"
eval "$("$(which -a conda | grep condabin)" shell.bash hook)"
run
