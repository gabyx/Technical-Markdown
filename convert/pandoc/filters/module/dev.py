import os


class FilterFlags:
    """
        Debug flags for the filters.
    """
    debugOutput = True
    teeOutput = os.path.join(os.getcwd(), "pandoc/filter-out")
^