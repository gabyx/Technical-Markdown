
import os

"""
    Debug flags for the filters.
"""
class FilterFlags:
    debugOutput = True
    teeOutput = os.path.join(os.getcwd(), "pandoc/filter-out")
