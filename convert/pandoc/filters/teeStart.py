#!/usr/bin/env python3
import sys
from module.tee import tee

assert sys.version_info >= (3, 0)
"""
    Unix-like tee for pandoc.
"""

if __name__ == "__main__":
    tee(clear=True)
