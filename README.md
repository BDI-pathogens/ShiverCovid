# About

The workflow includes the following software and steps:

- preprocessing
- shiver (https://github.com/ChrisHIV/shiver)
- iqtree (http://www.iqtree.org/)
- pangolin (https://github.com/cov-lineages/pangolin)
- qc

The workflow will fail upon error. Once an issue is resolved, it can be restarted and will do so at the point of failure.

# Prerequisites

- Miniconda 3
- Snakemake (compatible with release 5.5.4)
- shiver 1.5.8 (and associated prerequisites) *

The pipeline has been tested on a Linux environment using an SGE cluster.

The project relies on two Kraken databases, which are not yet part of this repo so this solution is not currently (standalone) portable.

\* The shiver package available in conda is out of date, and relies on `2to3`.

## Main conda environment

Ensure the conda environment exists:
```
conda activate covidenv
conda deactivate
```
If it doesn't exist, create it. E.g:
```
conda env create -f ./workflow/environment.yml
```

## Pangolin conda environment

Ensure the conda environment exists:
```
conda activate pangolin
conda deactivate
```
If it doesn't exist, create it using the instructions here:

https://github.com/cov-lineages/pangolin#install-pangolin

## Load Python 2

Ensure the correct version of Python 2 is loaded, i.e. where shiver and it's prerequisites are installed. E.g:
```
module load python/2.7.11
```

# Running

## Manual setup

1. Create a directory for data processing, e.g. `YYYY-MM-DD_<Batch Name(s)>`.

1. Navigate to that directory and clone this repo:
    ```
    git clone git@github.com:BDI-pathogens/ShiverCovid.git
    ```

1. Change directory:
    ```
    cd ShiverCovid/workflow
    ```

1. Replace all `"<to_be_completed>"` references in `_config.yaml` with information specific to your environment.

1. Prepare workflow files:
    ```
    ./prepare.sh <Raw Data Directory>
    ```

1. Execute the Snakemake workflow.

   A script has been provided to submit the job to an SGE cluster:
   - Replace `SGE_ROOT="<to_be_completed>"` with the approprate directory information in `submit.sh`.
   - Submit the jobs to the cluster: `nohup ./submit.sh &`
   
   Further information about executing Snakemake can be found in the documentation (https://snakemake.readthedocs.io/en/stable/).

### Completion flag

Once processing is complete, a flag file is created in the `COMPLETION_FLAG_DIR` defined in `_config.yaml`.

### Log files

The location of logs associated with each script will be detailed in the Snakemake output.
