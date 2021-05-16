import os


class FilterFlags:
    """
        Debug flags for the filters.
    """
    debugOutput = False
    teeOutput = os.path.join(os.getcwd(), "build/pandoc-filter-out")
