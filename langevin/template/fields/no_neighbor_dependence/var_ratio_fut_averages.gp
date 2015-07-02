#!/usr/bin/gnuplot

set terminal postscript eps color enhanced solid size 7cm,5cm
OUTFILE="var_ratio_fut_averages.eps"
set output OUTFILE

DATA="var_ratio_fut_averages_noweights.dat"

load gpmodel

set xlabel "Number of neighbours"
set ylabel "Mean ratio follower/neighbour variance"
set key Left top center
set grid
set log y
set ytics format "%.0e"

pl \
DATA notitle,\
DATA with yerror lt 1 title "No weights"

set output OUTFILE
set xrange [:1.05*GPVAL_X_MAX]
replot
