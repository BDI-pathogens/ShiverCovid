# About

The workflow includes:

- preprocessing
- shiver
- iqtree
- pangolin
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

1. Replace all `"<to_be_completed>"` references in `_config.yaml` and `submit.sh` with information specific to your environment.

1. Prepare workflow files:
    ```
    ./prepare.sh <Raw Data Directory>
    ```

1. Submit the jobs to the cluster:

    ```
    nohup ./submit.sh &
    ```

### Completion flag

Once processing is complete, a flag file is created in the `COMPLETION_FLAG_DIR` defined in `_config.yaml`.

### Log files

The main Snakemake output will be in `nohup.out`. The location of logs associated with each script will be detailed there.

### Processing failure

Upon failure:
 
1. Investigate the cause of the failure.

1. Perform any necessary remial action.

1. Submit the jobs as before. Snakemake will restart at the point of failure.

### Lock files

If a Snakemake process ends abruptly, some lock files may remain that will prevent a restart. Remove them as follows:

`rm .snakemake/locks/*`

### Rulegraph

To create a directed acyclic graph (DAG) of the rules:

`./rulegraph.sh`

This will output a file called `rulegraph.svg`.
