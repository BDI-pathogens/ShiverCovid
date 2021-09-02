"""

Basic script to take in insert size csv from shiver, where each row
is 3 comma-separated values (insert size, number of that size, fraction).

Returns the insert size at 0.05, 0.5, 0.95 percentiles, as well as
the number of inserts >350 and the fraction of inserts that are >350bp.

tanya.golubchik@bdi.ox.ac.uk
October 2017

"""

from __future__ import print_function

import sys
from os import path


def get_insert_size_stats(instrm, thresh=350):
    """
    Calculate insert size stats - values at .05/.5/.95 pc and number of inserts over a threshold size.
    """
    cumsum = 0.
    v05, v50, v95 = '', '', ''
    n_thresh = 0
    f_thresh = 0

    for l in instrm:
        try:
            iz, n, frac = l.split(',')
            iz = int(iz)
            frac = float(frac)
        except:
            continue
        if iz > thresh:
            n_thresh += int(n)
            f_thresh += frac
        cumsum += frac
        if not v05 and (cumsum >= 0.05):
            v05 = iz
        if not v50 and (cumsum >= 0.5):
            v50 = iz
        if not v95 and (cumsum >= 0.95):
            v95 = iz
    return v05, v50, v95, n_thresh, f_thresh


if __name__ == '__main__':
    if len(sys.argv) != 2 or not path.isfile(sys.argv[-1]):
        sys.stdout.write(',,,,\n')
        sys.stderr.write('Usage: {0} MyInsertSizeStats.csv\n'.format(sys.argv[0]))
        sys.exit(1)
    with open(sys.argv[1]) as instrm:
        v05, v50, v95, n_thresh, f_thresh = get_insert_size_stats(instrm, thresh=350)
    sys.stdout.write('{0},{1},{2},{3},{4}\n'.format(v05, v50, v95, n_thresh, f_thresh))
