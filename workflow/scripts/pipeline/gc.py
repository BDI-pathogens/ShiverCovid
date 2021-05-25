from __future__ import print_function

import gzip
import os
import sys
from decimal import Decimal


def calculate_gc(inpath):
    inf = gzip.open(inpath) if inpath.endswith('.gz') else open(inpath)
    ttl_bases = 0
    gc_bases = 0
    for i, l in enumerate(inf):
        if i % 4 == 1:
            s = l.strip().upper()
            ttl_bases += len(s)
            gc_bases += (s.count('G') + s.count('C'))
    return gc_bases, ttl_bases


if __name__ == '__main__':
    if not len(sys.argv) > 1 or not os.path.isfile(sys.argv[1]):
        sys.stderr.write('Usage: gc.py <fastq[.gz] file with no blank lines>\n')
        sys.exit(1)
    gc, ttl = calculate_gc(sys.argv[1])
    # The original pipeline returns 12 decimal places, so round this for consistency
    calc = round(Decimal(gc / float(ttl)), 12)
    print(gc, ttl, calc)
