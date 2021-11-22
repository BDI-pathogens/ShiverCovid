[![PEP8 Python 3.7](https://github.com/BDI-pathogens/ShiverCovid/actions/workflows/pep8.yml/badge.svg)](https://github.com/BDI-pathogens/ShiverCovid/actions/workflows/pep8.yml)
[![Shellcheck](https://github.com/BDI-pathogens/ShiverCovid/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/BDI-pathogens/ShiverCovid/actions/workflows/shellcheck.yml)

# About

The pipeline includes the following software and steps:

- preprocessing
- shiver (https://github.com/ChrisHIV/shiver)
- iqtree (http://www.iqtree.org/)
- pangolin (https://github.com/cov-lineages/pangolin)
- qc

The snakemake workflow will fail upon error. Once an issue is resolved, it can be restarted and will do so at the point of failure.

# Prerequisites

- Miniconda 3
- Snakemake
- shiver 1.5.8 (and associated prerequisites) *

The pipeline has been tested on a Linux environment using an SGE cluster.

The project relies on a Kraken 2 database, which is not yet part of this repo so this solution is not currently (standalone) portable.

\* The shiver package available in conda is out of date, and relies on `2to3`.

## Main conda environment

Ensure the conda environment exists:
```
conda activate shivercovid
conda deactivate
```
If it doesn't exist, create it. E.g:
```
conda env create -f ./snakemake/environment.yml
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

1. Create a directory for data processing of the form `YYYY-MM-DD_<Batch Name(s)>` and navigate to that directory.

1. Create a `samples.txt` file containing a list of samples for processing, with one sample per row.

1. Clone this repo:
    ```
    git clone git@github.com:BDI-pathogens/ShiverCovid.git
    ```

1. Change directory:
    ```
    cd ShiverCovid
    ```

1. Replace all `<to_be_completed>` references in `./snakemake/_config.yaml` with information specific to your environment.

1. Run the preprocessing script:
    ```
    ./scripts/preprocessing/setup.sh
    ```
   You will be prompted for input parameter(s).

1. Execute the Snakemake workflow.

   A script has been provided to submit the job to an SGE cluster: `./snakemake/submit.sh`
   
   Further information about executing Snakemake can be found in the documentation (https://snakemake.readthedocs.io/en/stable/).

### Completion flag

Once processing is complete, a flag file is created in the `COMPLETION_FLAG_DIR` defined in `_config.yaml`.

### Log files

The location of logs associated with each script will be detailed in the Snakemake output.
