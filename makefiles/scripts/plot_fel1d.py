#!/usr/bin/env python
#Write plots of 1D histograms in several files filenameroot-V#.fel1d
#Where # = 01, 02, ... to file.fel1d_##.tex
#Infile format: "x y [yerr]" in each file

import sys, os
import numpy as np
import Gnuplot, Gnuplot.funcutils

if len(sys.argv) != 8:
    sys.exit(("Usage: %s filenameroot histdir cols_per_plot nthplot lastplot"
            + " pseudo_reffilename yrange") % sys.argv[0])

suffix = "fel1d"
filenameroot = sys.argv[1]
datadir = sys.argv[2]
cols_per_plot = int(sys.argv[3])
nthplot = int(sys.argv[4])
lastplot = int(sys.argv[5])
reffileroot = sys.argv[6]
if reffileroot:
    reffileroot = sys.argv[6].split("/")
    reffileroot.insert(-1,datadir)
    reffileroot = os.path.join(*reffileroot)
y_range = sys.argv[7].strip().split(":")

# read data from selected files filenameroot-V[0-9][0-9]+.suffix
data = []
offset = (nthplot-1)*cols_per_plot
if reffileroot:
    refdata = []
    for i in range(1+offset, 1+min(nthplot*cols_per_plot,lastplot)):
        filename = reffileroot+("-V%02d.%s" % (i, suffix))
        refdata.append(np.loadtxt(filename))
for i in range(1+offset, 1+min(nthplot*cols_per_plot,lastplot)):
    filename = os.path.join(datadir, filenameroot+("-V%02d.%s" % (i, suffix)))
    data.append(np.loadtxt(filename))
del(filename)

# number of files read = number of columns in plot
ncols = len(data)

# configuration
g = Gnuplot.Gnuplot()
g.xlabel('Principal component')
g.ylabel('Free energy $F - F_0$ [kT]')
g.title(r'1D free energy landscape for \\verb|%s|' % filenameroot)
settings = [ 'terminal tikz standalone tightboundingbox',
    'mxtics', 'mytics', 'grid',
    'key out bottom center horizontal width +1']
if len(y_range) == 2:
    # set yrange if specified
    settings.append("yrange [%s:%s]" % tuple(y_range))
for setting in settings:
    g('set %s' % setting)

# generate two plots with and without errorbars
outfilenameroot = "%s.%s_%02d" % (filenameroot, suffix, nthplot)
if reffileroot:
    r = []
    for i in range(ncols):
        r.append(Gnuplot.Data(refdata[i], cols=(0,1,2)))
    g('set output "%s"' % (outfilenameroot+'e.tex'))
    g('set xrange [] writeback')
    g.plot(*r)
    g('set xrange restore')
d = []
for i in range(ncols):
    d.append(Gnuplot.Data(data[i], cols=(0,1,2),
        title=('V%s' % str(i+offset+1))))
g('set style data yerrorlines')
g('set output "%s"' % (outfilenameroot+'e.tex'))
g.plot(*d)
g('set style data lines')
g('set output "%s"' % (outfilenameroot+'n.tex'))
g.replot()
