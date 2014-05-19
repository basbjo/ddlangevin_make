#!/usr/bin/env python
#Calculate free energies from 1D histogram
#Infile format: "x y yerr [integer]"
#Returns "x kT_factor*(-log(y)+log(y_max)) kT_factor*yerr/y [integer]"

import sys
import re
import numpy as np

if len(sys.argv) != 4:
    print("Usage: %s filename minmaxfile kT_factor" % sys.argv[0])
    sys.exit(1)

filename = sys.argv[1]
minmaxfile = sys.argv[2]
kT_factor = sys.argv[3]
data = np.loadtxt(filename)

# remove lines with zeros
data = data[data[:,1]!=0]

# factor for temperature rescaling (optional)
if kT_factor:
    kT_factor = float(kT_factor)
else:
    kT_factor = 1

# get minima and maxima from file (optional)
if minmaxfile:
    minmax = np.loadtxt(minmaxfile)
    if len(minmax) != 2:
        sys.exit("Error: '%s' has wrong format." % minmaxfile)
    # determine column from '-V#' in filename
    m = re.match(".*-V([0-9]+).*", filename.split('/')[-1])
    if not m:
        sys.exit(("Error: Cannot determine column from filename '%s'"
                +" (need '-V##')") % filename)
    column = int(m.groups()[0])
    minimum, maximum = sorted(minmax[:,column-1])
    data = data[data[:,0]>=minimum]
    data = data[data[:,0]<=maximum]

# calculation
data[:,2] = kT_factor*data[:,2]/data[:,1]
data[:,1] = -kT_factor*np.log(data[:,1]) +kT_factor*np.log(max(data[:,1]))

# write result to stdout
sys.stdout.write("#1D free energy landscape derived from %s\n" % filename)
sys.stdout.write("#kT_factor = %s\n" % kT_factor)
fmt = " ".join(3*["%.6e"])
if data.shape[1] == 4:
    fmt += " %d"
np.savetxt(sys.stdout, data, fmt=fmt)
