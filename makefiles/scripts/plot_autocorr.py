#!/usr/bin/env python
#Write plots of autocorrelations in several files filenameroot-V#.cor
#Where # = 01, 02, ... to file.cor_##n.tex and file.cor_##e.tex
#Infile format: "x y [yerr]" in each file

import sys, os
import numpy as np
import Gnuplot, Gnuplot.funcutils

if len(sys.argv) != 8:
    sys.exit(("Usage: %s filenameroot cordir cols_per_plot nthplot lastplot"
            + " xrange unit") % sys.argv[0])

suffix = "cor"
filenameroot = sys.argv[1]
datadir = sys.argv[2]
cols_per_plot = int(sys.argv[3])
nthplot = int(sys.argv[4])
lastplot = int(sys.argv[5])
x_range = sys.argv[6].strip().split(":")
unit = sys.argv[7].strip()
if unit:
    step = float(filenameroot.split(unit)[0].split('_')[-1])
    unit = ' [%s]' % unit
else:
    step = 1.0

# read data from selected files filenameroot-V[0-9][0-9]+.suffix
data = []
offset = (nthplot-1)*cols_per_plot
for i in range(1+offset, 1+min(nthplot*cols_per_plot,lastplot)):
    filename = os.path.join(datadir, filenameroot+("-V%02d.%s" % (i, suffix)))
    data.append(np.loadtxt(filename))
del(filename)

# number of files read = number of columns in plot
ncols = len(data)

# configuration
g = Gnuplot.Gnuplot()
g.xlabel('Time%s' % unit)
g.ylabel('Normalized autocorrelation')
g.title(r'Autocorrelations for \\verb|%s|' % filenameroot)
settings = [ 'terminal tikz standalone tightboundingbox',
    'mxtics', 'mytics', 'grid', 'log x', 'yrange [0:1]',
    'ytics (0, 0.25, "$e^{-1}$" exp(-1), 0.5, 0.75, 1.0) format "%.2f"']
if len(x_range) == 2:
    # set xrange if specified
    settings.append("xrange [%s:%s]" % tuple(x_range))
for setting in settings:
    g('set %s' % setting)

# generate two plots with and without errorbars
outfilenameroot = "%s.%s_%02d" % (filenameroot, suffix, nthplot)
d = []
for i in range(ncols):
    x = data[i][:,:1]*step
    y = data[i][:,1:]
    d.append(Gnuplot.Data(np.concatenate([x, y], axis=1),
        cols=(0,1,2),
        title=('V%s' % str(i+offset+1))))
g('set style data yerrorlines')
g('set output "%s"' % (outfilenameroot+'e.tex'))
g.plot(*d)
g('set style data lines')
g('set output "%s"' % (outfilenameroot+'n.tex'))
g.replot()
