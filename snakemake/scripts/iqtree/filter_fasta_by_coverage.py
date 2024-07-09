import argparse
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


def ungap(seq_object, gap_char='-'):
    """Try both replace and ungap on seq objects, flexible to Biopython version"""
    try:
        seq_ungapped = seq_object.replace(gap_char, "")
    except AttributeError:
        seq_ungapped = seq_object.ungap(gap_char)
    return seq_ungapped


def filter_seqs(args):
    """
    Filter to keep sequences with at most N% gaps.
    """
    if len(SeqIO.read(args.in_file, 'fasta')) > 0:
        record = SeqIO.read(args.in_file, 'fasta')
        if ungap(record.seq, '-').count(args.gap_char) / float(len(ungap(record.seq, '-'))) <= Decimal(args.gap_prop):
            print(f"File passes filter criteria. Writing to {args.out_file}")
            SeqIO.write(record, args.out_file, 'fasta')
        else:
            logging.info("File does not pass filter criteria")
            create_dummy_output_file(args.out_file)
    else:
        logging.info("Record length is zero")
        create_dummy_output_file(args.out_file)


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--in_file', dest='in_file', type=str, required=True)
    parser.add_argument('--gap_prop', dest='gap_prop', type=str, required=True)
    parser.add_argument('--gap_char', dest='gap_char', type=str, required=True)
    parser.add_argument('--out_file', dest='out_file', type=str, required=True)
    parser.add_argument('--log_file', dest='log_file', type=str, required=True)
    args = parser.parse_args()
    return args


def main():
    args = parse_arguments()

    logging.basicConfig(level=logging.INFO, filename=args.log_file, format='%(levelname)s:%(message)s')

    if os.stat(args.in_file).st_size == 0:
        logging.info("Input file is empty")
        create_dummy_output_file(args.out_file)
    else:
        validate_gap_prop(Decimal(args.gap_prop))
        filter_seqs(args)


if __name__ == '__main__':
    main()
