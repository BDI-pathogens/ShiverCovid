import logging
import os
import sys
from Bio import SeqIO
from pathlib import Path


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


def main():
    in_file = sys.argv[1]
    out_file = sys.argv[2]
    log_file = sys.argv[3]

    logging.basicConfig(level=logging.DEBUG, filename=log_file, format='%(levelname)s:%(message)s')

    if os.stat(in_file).st_size == 0:
        logging.info("Input file is empty")
        create_dummy_output_file(out_file)
    else:
        print(f"Writing to {out_file}")
        record = next(SeqIO.parse(in_file, 'fasta'))
        ungap_record.seq = ungap(record.seq, '-')
        SeqIO.write(ungap_record, out_file, 'fasta')


if __name__ == '__main__':
    main()
