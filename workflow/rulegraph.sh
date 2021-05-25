#!/usr/bin/env bash

snakemake --rulegraph --configfile config.yaml | dot -Tsvg >./images/rulegraph.svg
