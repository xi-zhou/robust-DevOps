import sys
from noiseTool.parser import Parser, sigterm_handler
import signal


def main():
    signal.signal(signal.SIGTERM, sigterm_handler)
    signal.signal(signal.SIGINT, sigterm_handler)
    parser = Parser()
    args = parser.parse_args()

    # Redirect all output to specified file
    if args.file_output is not None:
        sys.stdout = open(args.file_output, 'a')
        sys.stderr = sys.stdout  # Redirect stderr to the same file as stdout

    args.func(args)


if __name__ == '__main__':
    main()
