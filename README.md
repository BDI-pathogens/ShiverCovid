[![PEP8 Python 3.12](https://github.com/BDI-pathogens/ShiverCovid/actions/workflows/pep8.yml/badge.svg)](https://github.com/BDI-pathogens/ShiverCovid/actions/workflows/pep8.yml)
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

- Slurm Workload Manager
- Miniconda 3
- Snakemake

The pipeline has been tested on a Linux environment using a Slurm Workload Manager.

The project relies on a Kraken 2 database, which is not yet part of this repo so this solution is not currently (standalone) portable.

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

# Running

## Manual setup

1. Create a directory for data processing of the form `YYYY-MM-DD_<Batch Name(s)>` and navigate to that directory.

2. Create a `samples.txt` file containing a list of samples for processing, with one sample per row.

3. Clone this repo:
    ```
    git clone git@github.com:BDI-pathogens/ShiverCovid.git
    ```
   
4. Change directory:
    ```
    cd ShiverCovid
    ```

5. Replace all `<to_be_completed>` references in `./snakemake/_config.yaml` with information specific to your environment.

6. Run the preprocessing script:
    ```
    ./scripts/preprocessing/setup.sh
    ```
   You will be prompted for input parameter(s).

7. Activate the conda environment:
   ```
   conda activate shivercovid
   ```
   
8. Execute the Snakemake workflow.

   A script has been provided to submit the job to a Slurm Workload Manager: `./snakemake/submit.sh`
   
   Further information about executing Snakemake can be found in the documentation (https://snakemake.readthedocs.io/en/stable/).

### Log files

The location of logs associated with each script will be detailed in the Snakemake output.
