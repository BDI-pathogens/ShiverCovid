import os
import sys


def format_file(in_file, tag):
    try:
        with open(in_file, 'r') as f_in:
            for count, value in enumerate(f_in):
                if not count % 4:
                    sys.stdout.write('{0}/{1}\n'.format(value.split()[0].rsplit('/', 1)[0], tag))
                else:
                    sys.stdout.write(value)
        # https://docs.python.org/3/library/signal.html#note-on-sigpipe
        # flush output here to force SIGPIPE to be triggered
        # while inside this try block.
        sys.stdout.flush()
    except BrokenPipeError:
        # Python flushes standard streams on exit; redirect remaining output
        # to devnull to avoid another BrokenPipeError at shutdown
        devnull = os.open(os.devnull, os.O_WRONLY)
        os.dup2(devnull, sys.stdout.fileno())
        sys.exit(1)  # Python exits with error code 1 on EPIPE


def main():
    format_file(sys.argv[1], sys.argv[2])


if __name__ == '__main__':
    main()
