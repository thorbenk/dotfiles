#!/usr/bin/env python3

# source: https://github.com/alacritty/alacritty/issues/1093

# Note this does not generate the 'cursor:' section becuase I don't know what would correspond to that.
# I also dont know if theres an equivalent light/dark for the foreground/background so those are ignored.
# Also alacritty does not have "dark" colors. (?)

import sys
import configparser as confp  # ini format
import yaml
import collections

# fixes extraneous stuff when yaml-ing a defaultdict
from yaml.representer import Representer

yaml.add_representer(collections.defaultdict, Representer.represent_dict)

confpath = sys.argv[1]
c = confp.ConfigParser()
c.read(confpath)

colormap = {
    "Color0": "black",
    "Color1": "red",
    "Color2": "green",
    "Color3": "yellow",
    "Color4": "blue",
    "Color5": "magenta",
    "Color6": "cyan",
    "Color7": "white",
    "Foreground": "foreground",
    "Background": "background",
}

typemap = {"Intense": "bright", "Faint": "dim", "#default#": "normal"}


def stype(s):
    for k, v in typemap.items():
        if s.endswith(k):
            return v
    return typemap["#default#"]


def ctype(sb):
    for k, v in colormap.items():
        if s.startswith(k):
            return v
    raise NotImplementedError


def hexcolor(s):
    tohex = lambda x: "{0:02x}".format(int(x))
    return "0x%s" % "".join([tohex(x) for x in s.split(",")])


data = {"colors": collections.defaultdict(dict)}

for s in c.sections():
    if "color" in c[s]:
        if ctype(s) in ["foreground", "background"]:
            if stype(s) == "normal":
                data["colors"]["primary"][ctype(s)] = hexcolor(c[s]["color"])
            else:
                data["colors"]["primary"][f"{stype(s)}_{ctype(s)}"] = hexcolor(
                    c[s]["color"]
                )
            continue
        data["colors"][stype(s)][ctype(s)] = hexcolor(c[s]["color"])

print(yaml.dump(data, default_flow_style=False))
