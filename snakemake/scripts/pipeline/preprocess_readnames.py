from sys import stdout, argv


def format_file(in_file, tag):
    with open(in_file, 'r') as f_in:
        for count, value in enumerate(f_in):
            if not count % 4:
                stdout.write('{0}/{1}\n'.format(value.split()[0].rsplit('/', 1)[0], tag))
            else:
                stdout.write(value)


def main():
    format_file(argv[1], argv[2])


if __name__ == '__main__':
    main()
