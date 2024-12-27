#!/usr/bin/env python3
# Copyright (c) 2024 Beijing Institute of Open Source Chip
# OpenNoC is licensed under Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
#          http://license.coscl.org.cn/MulanPSL2
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
#
# Author:
#    Jianxing Wang <wangjianxing@bosc.ac.cn>
#
# Generate OpenNoC Mesh

import argparse
import json
from dataclasses import dataclass
from enum import *
from jinja2 import Environment, FileSystemLoader

@dataclass
class PortEnum(Enum):
    NONE = "NONE"
    RNF = "RNF"
    RNI = "RNI"
    HNF = "HNF"
    HNI = "HNI"
    SNF = "SNF"

@dataclass
class CrossPoint:
    name: str
    X: int
    Y: int
    P0: PortEnum
    P1: PortEnum
    def __init__(self, name:str = "XP", obj:dict = None):
        self.name = name
        self.X = obj["X"]
        self.Y = obj["Y"]
        self.P0 = PortEnum(obj["P0"])
        self.P1 = PortEnum(obj["P1"])

x_max = 1
y_max = 1
mesh_cfg = []
def main():
    global mesh_cfg
    parser = argparse.ArgumentParser(description="Generate OpenNoC Mesh Wrapper")
    parser.add_argument('-f', '--file',  type=str, help="mesh configure file")
    args = parser.parse_args()

    if args.file is None:
        parser.print_help()
        exit(-1)

    with open(args.file, 'r') as mesh_cfg_file:
        cfg_data = json.load(mesh_cfg_file)
        verify_cfg(cfg_data)
        if (x_max + 1) * (y_max + 1) != len(cfg_data):
            print("Found Error Configuration")
            exit(-1)
        print(mesh_cfg)
        generate(x_max, y_max, mesh_cfg)

def verify_cfg(cfg_data):
    global x_max
    global y_max
    global mesh_cfg
    for key in cfg_data:
        xp = cfg_data[key]
        if xp["X"] > x_max:
            x_max = xp["X"]
        if xp["Y"] > y_max:
            y_max = xp["Y"]
        route_node = CrossPoint(key, xp)
        mesh_cfg.append(route_node)

def generate(x_max : int = 1, y_max : int = 1, cfg : list = None):
    module = "mesh_wrapper_{0}x{1}".format(x_max + 1, y_max + 1)

    print('Generate Mesh Wrapper {0}.sv'.format(module))

    env = Environment(loader=FileSystemLoader('template'))
    env.trim_blocks = True
    env.lstrip_blocks = True
    template = env.get_template('mesh_wrapper.j2')
    with open(module + ".sv", 'w', encoding='UTF-8') as f:
        f.write(template.render(xmax = x_max, ymax = y_max, module = module, nodes = cfg))

if __name__ == "__main__":
    main()
