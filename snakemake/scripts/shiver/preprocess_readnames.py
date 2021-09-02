from __future__ import print_function

import gzip
import sys


def cleanit(inpath, tag):
    inf = gzip.open(inpath) if inpath.endswith('.gz') else open(inpath)
    for i, l in enumerate(inf):
        if not i % 4:
            sys.stdout.write('{0}/{1}\n'.format(l.split()[0].rsplit('/', 1)[0], tag))
        else:
            sys.stdout.write(l)
    inf.close()


if __name__ == '__main__':
    try:
        cleanit(sys.argv[1], sys.argv[2])
    except:
        sys.stderr.write('Usage: {0} /path/to/fastq[.gz] READ-SUFFIX-TO-ADD\n\n'.format(sys.argv[0]))
