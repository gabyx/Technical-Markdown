import sys


def log(fmt, name, *args, **kwargs):
    if args or kwargs:
        print(name + ":: " + fmt.format(*args, **kwargs), file=sys.stderr)
    else:
        print(name + ":: " + fmt, file=sys.stderr)
