#!/usr/bin/env python
#Plot cumulative variances

import sys
import numpy as np
import Gnuplot, Gnuplot.funcutils

if len(sys.argv) != 2:
    sys.exit("Usage: %s filename" % sys.argv[0])

filename = sys.argv[1]

data = np.loadtxt(filename)
cumulated = 0
for i,value in enumerate(data):
    cumulated += value
    data[i] = cumulated
data *= 100.0/cumulated
xvals = np.arange(len(data)) + 0.5

g = Gnuplot.Gnuplot()
g.xlabel(r'\\# $V_i$')
g.ylabel(r'Cumulative variances [\\%]')
g.title(r'Cumulative variances from \\verb|%s|' % filename)
settings = ['terminal tikz standalone tightboundingbox',
    'xtics nomirror', 'mytics 2',
    'grid', 'grid mytics', 'grid noxtics',
    'style data boxes', 'yrange [0:100]',
    'output "%s"' % (filename+'.tex')]
for setting in settings:
    g('set %s' % setting)
g.plot(Gnuplot.Data(xvals, data))
