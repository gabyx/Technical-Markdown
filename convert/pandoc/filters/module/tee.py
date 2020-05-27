"""
    Tee function which drops the pandoc AST to a file
"""

import sys
import json
import os
import shutil
import io
from module.dev import FilterFlags as flags
from module.utils import log

fName = "tfClear"


def tee(clear=False):
    input_stream = io.TextIOWrapper(sys.stdin.buffer, encoding='utf-8')

    source = input_stream.read()
    file = None

    if len(sys.argv) >= 3:
        for a in sys.argv[2:]:
            if a == "--clear":
                clear = True
            else:
                file = a

    if clear and os.path.exists(flags.teeOutput):
        log("Clear output '{0}'", fName, flags.teeOutput)
        shutil.rmtree(flags.teeOutput)

    if not file:
        if not os.path.exists(flags.teeOutput):
            os.makedirs(flags.teeOutput)

        file = os.path.join(flags.teeOutput, "tee")

        # Increment counter ...
        i = 1

        def filename(x):
            file + "-{0}.json".format(x)

        t = filename(i)
        while os.path.exists(t):
            i += 1
            t = filename(i)
        file = t

    if file:
        log("Write pandoc AST to '{0}'", fName, file)
        js = json.loads(source)
        with open(file, "w") as f:
            json.dump(js, f, indent=4)

    # Pass it on
    sys.stdout.write(source)
