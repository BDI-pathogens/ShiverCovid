#!/usr/bin/env bash

# Check the status of a Slurm job
# This allows memory and timeout issues to be caught
jobid="${1}"

output=$($(which sacct) -j "${jobid}" --format State --noheader | head -n 1 | awk '{print $1}')

if [[ "${output}" =~ ^(COMPLETED).* ]]; then
  echo "success"
elif [[ "${output}" =~ ^(RUNNING|PENDING|COMPLETING|CONFIGURING|SUSPENDED).* ]]; then
  echo "running"
else
  echo "failed"
fi
