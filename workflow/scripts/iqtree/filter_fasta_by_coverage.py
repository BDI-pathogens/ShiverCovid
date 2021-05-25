import logging
import os
import sys
from decimal import Decimal
from pathlib import Path

from Bio import SeqIO


def validate_gap_prop(gap_prop):
    if not 0 <= gap_prop <= 1:
        logging.error("Proportion of gaps must be in range (0, 1). Exiting...")
        sys.exit(1)


def create_dummy_output_file(out_file):
    logging.info("Creating dummy output file...")
    Path(out_file).touch()


def filter_seqs(in_file, gap_prop, gap_char, out_file):
    """
    Filter to keep sequences with at most N% gaps.
    """
    if len(SeqIO.read(in_file, 'fasta')) > 0:
        record = SeqIO.read(in_file, 'fasta')
        if record.seq.ungap('-').count(gap_char) / float(len(record.seq.ungap('-'))) <= gap_prop:
            print(f"File passes filter criteria. Writing to {out_file}")
            SeqIO.write(record, out_file, 'fasta')
        else:
            logging.info("File does not pass filter criteria")
            create_dummy_output_file(out_file)
    else:
        logging.info("Record length is zero")
        create_dummy_output_file(out_file)


def main():
    in_file = sys.argv[1]
    gap_prop = Decimal(sys.argv[2])
    gap_char = sys.argv[3]
    out_file = sys.argv[4]
    log_file = sys.argv[5]

    logging.basicConfig(level=logging.INFO, filename=log_file, format='%(levelname)s:%(message)s')

    if os.stat(in_file).st_size == 0:
        logging.info("Input file is empty")
        create_dummy_output_file(out_file)
    else:
        validate_gap_prop(gap_prop)
        filter_seqs(in_file, gap_prop, gap_char, out_file)


if __name__ == '__main__':
    main()
