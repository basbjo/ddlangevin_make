#!/usr/bin/gnuplot

set terminal postscript eps color enhanced solid size 7cm,5cm
OUTFILE="friction_averages.eps"
set output OUTFILE
#replot

gpmodel="../../../../model.gp"

DATA="friction_averages_noweights"

load gpmodel

set xlabel "Number of neighbours"
set ylabel "Friction average"
set key Left top center
set grid
set yrange [0:60]
set ytics format "%3.0f"

pl \
DATA notitle,\
DATA with yerror lt 1 title "No weights",\
30 lt -1 title "True value"

set output OUTFILE
set xrange [:1.05*GPVAL_X_MAX]
replot
