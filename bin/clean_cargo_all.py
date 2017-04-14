#!/usr/bin/env python3

"""
Usage: ./clean_cargo_all <root_dir>

Find all project directories containg a `Cargo.toml` and run
`cargo clean` in them.
"""

import os
import sys

def find_dirs_with_file(root_dir, file_name):
    result = []
    for root, dirs, files in os.walk(root_dir):
        if file_name in files:
            result.append(root)
    return sorted(result)

def make_clean_cargo_cmd(root_dir):
    dirs = find_dirs_with_file(root_dir, "Cargo.toml")
    cmds = list(map(lambda d: "cd %s && cargo clean" % d, dirs))
    cmds.append("cd %s" % os.getcwd())
    return " && \\\n".join(cmds)

if __name__ == "__main__":
    root_dir = sys.argv[1]
    print("Run the following command:\n")
    print(make_clean_cargo_cmd(root_dir))
