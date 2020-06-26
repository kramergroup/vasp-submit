#!/usr/bin/env python3
"""Get a reasonable number of nodes Nn on Iridis5 given the size N of the system.

From experience, up to 6 atoms are fine on 1 node (40CPUs) for using PBE with Encut 650eV Kdens=17x17x1.
Thus, reserve Nn=ceil(N/6+1/2) nodes, up to a maximum of 4 (more than 160 CPUs VASP becoms sluggish).
"""
import sys, math
from ase.io import read as ase_read

geom = ase_read(sys.argv[1], format='vasp')
Nn = math.ceil(len(geom)/6)
if Nn > 4: Nn = 4
print(Nn)
