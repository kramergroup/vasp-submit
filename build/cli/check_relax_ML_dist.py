#!/usr/bin/env python3

from ase.io import read as ase_read

def check_relax_ML_dist():
    g0 = ase_read("POSCAR")
    g1 = ase_read("run.final/CONTCAR")

    # Compute layer thickness
    t0 = max(g0.positions[:,2]) - min(g0.positions[:,2])
    t1 = max(g1.positions[:,2]) - min(g1.positions[:,2])

    # Compute distance between ML
    d0 = g0.cell[2,2] - t0
    d1 = g1.cell[2,2] - t1

    print("d0=%.3f Ang" % d0, "d1=%.3f Ang" % d1)
    print("Diff=%5.2g Ang reldiff=%5.2g%%" % (d0-d1, 100*(d0-d1)/d0))

    return d0, d1

if __name__ == "__main__":
    d0, d1 = check_relax_ML_dist()
    d_tol = 12 # Ang. Less than this between the layers is suspicious
    if d1 < d_tol:
        print("WARNING: ML images are suspiciously close. Check relaxation")
