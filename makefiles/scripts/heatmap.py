#!/usr/bin/env python
#Plot heatmap (2d histogram) read from ASCII data

# Copyright (c) 2014, Florian Sittel (www.lettis.net)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import subprocess
import sys
import argparse
import numpy as np
import matplotlib
import re

def nbins_ext(x,y):
    """
    Returns [nbinsx, nbinsy, ext] which are the number of
    bins and a four-tuple containing the plot extension.

    @type x: np.ndarray
    @type y: np.ndarray
    @rtype: tuple
    """
    nbinsx = len(set(x))
    nbinsy = len(set(y))
    sizex = (max(x)-min(x))/(nbinsx-1)
    sizey = (max(y)-min(y))/(nbinsy-1)
    ext = (min(x)-sizex/2, max(x)+sizex/2,
           min(y)-sizey/2, max(y)+sizey/2)
    return nbinsx, nbinsy, ext

#######

def plotHeatmap(col_x,
                col_y,
                col_value,
                file_in=None,
                pdf_out=None,
                title=None,
                z_min=None,
                z_max=None,
                z_ref_file=None,
                xy_ref_file=None,
                ref_file=None,
                cmd_on_select=None):
  """plot heatmap (2d histogram) read from ASCII data (e.g.
     from a file generated by the TISEAN-binary 'histo2d').
     col_x, col_y and col_value (all integers) denote the columns
     to read from, with counting beginning with 1.
     the largest value of col_value will be ignored.
     if given, 'title' is set as plot title.
     if given, 'pdf_out' is a filename of a pdf-file to which the heatmap will be saved
     if given, the z_min and z_max values to control the 'heat'-coloring by adjusting the z-axis.
     if given, the z_ref_file is used to set z_min and z_max as if z_ref_file were the data file.
     if given, the xy_ref_file is used to set visible xrange and yrange in analogy to z_ref_file.
     if given, ref_file is used as z_ref_file and xy_ref_file unless they are already given.
     instead of being interactively shown on screen."""
  if z_ref_file or ref_file:
    # get z-range from reference file
    if not z_ref_file:
        z_ref_file = ref_file
    zref = np.loadtxt(z_ref_file).T[col_value-1]
    zref = zref[np.isnan(zref)==False]
    zref = zref[zref!=max(zref)]
    z_min = min(zref)
    z_max = max(zref)
    del(zref)
  if xy_ref_file or ref_file:
    # get x-/y-ranges from reference file
    if not xy_ref_file:
        xy_ref_file = ref_file
    xyref = np.loadtxt(xy_ref_file, usecols=(col_x-1, col_y-1))
    nbinsx, nbinsy, refext = nbins_ext(xyref.T[0], xyref.T[1])
    del(xyref)
  else:
    refext = None
  if file_in:
    data = np.loadtxt(file_in, usecols=(col_x-1, col_y-1, col_value-1))
    x = data.T[0]
    y = data.T[1]
    val = data.T[2]
  else:
    x = []
    y = []
    val = []
    for line in sys.stdin:
      line = line.strip().split()
      if len(line) >= 3 and line[0][0] != "#":
        x.append(float(line[col_x-1]))
        y.append(float(line[col_y-1]))
        val.append(float(line[col_value-1]))
    x = np.array(x)
    y = np.array(y)
    val = np.array(val)
  nbinsx, nbinsy, ext = nbins_ext(x, y)
  hist = np.zeros((nbinsy,nbinsx))
  for i in xrange(nbinsx):
    for j in xrange(nbinsy):
      # swap indices for proper alignment of axis
      hist[j][i] = val[i*nbinsy+j]
  hist[hist==max(val)] = None

  if pdf_out:
    matplotlib.use('Agg')
  else:
    matplotlib.use('QT4Agg')
  import matplotlib.pyplot as plt
  if pdf_out:
      plt.figure(figsize=(6, 4.5))
  else:
      plt.figure()
  if title:
      # insert newline after units in filenames
      title = re.sub(r'(_[0-9]+[A-Za-z]+)\.', r'\1\n', title)
      plt.title(title+"\n")
  ax = plt.subplot(111)
  if refext:
    plt.xlim((refext[0], refext[1]))
    plt.ylim((refext[2], refext[3]))
  plt.imshow(hist, extent=ext, interpolation='nearest', origin='lower',
          aspect='auto', vmin=z_min, vmax=z_max)
  plt.colorbar()
  if pdf_out:
    plt.savefig(pdf_out, bbox_inches='tight')
  else:
    # if a command has been given, add a selection handler for rectangular
    # selection and execute command with selected coordinates
    if cmd_on_select:
      def select_handler(p1, p2, cmd):
        """replace #x1, #y1, ... fields in cmd by actual values and execute cmd."""
        x1 = p1.xdata
        y1 = p1.ydata
        x2 = p2.xdata
        y2 = p2.ydata
        cmd = cmd.replace("#x1", str(x1)).replace("#y1", str(y1)).replace("#x2", str(x2)).replace("#y2", str(y2))
        subprocess.Popen(cmd, shell=True)
      span = matplotlib.widgets.RectangleSelector(ax,
              lambda p1, p2: select_handler(p1, p2, cmd_on_select),
              rectprops={'alpha': 0.5, 'fill': True})

    plt.show()

#######


if __name__ == "__main__":
  parser = argparse.ArgumentParser("heatmap", description="plot heatmap from 2D-histogram")

  parser.add_argument("-o",
                      dest="pdf_out",
                      default=None,
                      help="save heatmap to pdf instead of plotting it interactively.")
  parser.add_argument("-t",
                      dest="title",
                      default=None,
                      help="set plot title.")
  parser.add_argument("-c", "--columns",
                      dest="columns",
                      default="1,2,5",
                      help="""comma-separated list of columns with x, y, and value of histogram.
                              x must be the column with major counting (i.e. for every value in x
                              first all according values of y are given before the next value in
                              x is used).
                              default: 1,2,5 (logs from histo2d)""")
  parser.add_argument("--on-select",
                      dest="on_select",
                      default=None,
                      help="""define command to run on rectangle selection. x/y coordinates of selection
                              corners will be made available by the variable #x1, #y1, #x2, #y2.
                              e.g., to write the coordinates of the two corners defining the selected
                              range to file, write: --on-select 'echo "#x1 #y1 #x2 #y2" > FILENAME'.""")
  parser.add_argument("input_file", metavar="INPUT", type=str, nargs='?',
                      help="input file. if not given will read from STDIN.")
  parser.add_argument("--z-min",
                      dest="z_min",
                      default=None,
                      type=float,
                      help="""minimum value of z-axis.""")
  parser.add_argument("--z-max",
                      dest="z_max",
                      default=None,
                      type=float,
                      help="""maximum value of z-axis.""")
  parser.add_argument("--z-ref",
                      dest="z_ref_file",
                      default=None,
                      type=str,
                      help="""reference file to set z-range (infile format).""")
  parser.add_argument("--xy-ref",
                      dest="xy_ref_file",
                      default=None,
                      type=str,
                      help="""reference file to set visible x-/y-ranges.""")
  parser.add_argument("--ref",
                      dest="ref_file",
                      default=None,
                      type=str,
                      help="""reference file to set all ranges.""")
  args = parser.parse_args()

  cols = args.columns.strip().split(',')
  if not len(cols) == 3:
    print "error: please give exactly three column indices for x, y and values. e.g. -c 1,2,5"
  else:
    plotHeatmap(int(cols[0]),
                int(cols[1]),
                int(cols[2]),
                file_in=args.input_file,
                pdf_out=args.pdf_out,
                title=args.title,
                z_min=args.z_min,
                z_max=args.z_max,
                z_ref_file=args.z_ref_file,
                xy_ref_file=args.xy_ref_file,
                ref_file=args.ref_file,
                cmd_on_select=args.on_select)

