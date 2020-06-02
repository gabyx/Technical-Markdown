import sys


def log(fmt, name, *args, **kwargs):
    """
        Log to stderr because stdout is used by the filter.
    """
    if args or kwargs:
        print(name + ":: " + fmt.format(*args, **kwargs), file=sys.stderr)
    else:
        print(name + ":: " + fmt, file=sys.stderr)
