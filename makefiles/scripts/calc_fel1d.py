#!/usr/bin/env python
#Calculate free energies from several 1D histograms
#Infile format: "xi yi yerri" triples for i = 1,2,...
#Returns "xi kT_factor*(-log(yi)+log(yi_max)) kT_factor*yerri/yi" triples

import sys
import numpy as np

if len(sys.argv) != 3:
    print("Usage: %s filename kT_factor" % sys.argv[0])
    sys.exit(1)

filename = sys.argv[1]
kT_factor = sys.argv[2]
data = np.loadtxt(filename)
ncols = data.shape[1]/3

# remove lines with zeros
data = data[data[:,1]!=0]

# factor for temperature rescaling (optional)
if kT_factor:
    kT_factor = float(kT_factor)
else:
    kT_factor = 1

# calculation
for i in range(ncols):
    data[:,3*i+2] = (kT_factor*data[:,3*i+2]/data[:,3*i+1])
    data[:,3*i+1] = (-kT_factor*np.log(data[:,3*i+1])
                     +kT_factor*np.log(max(data[:,3*i+1])))

# write result to stdout
sys.stdout.write("#1D free energy landscapes derived from %s\n" % filename)
sys.stdout.write("#kT_factor = %s\n" % kT_factor)
np.savetxt(sys.stdout, data, fmt="%.6e")
