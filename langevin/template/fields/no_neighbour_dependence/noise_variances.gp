#!/usr/bin/gnuplot

set terminal postscript eps color enhanced solid size 7cm,5cm
set output "noise_variances.eps"
#replot

gpmodel="../../../../model.gp"

DATA="noise_variances_noweights"

load gpmodel

set xlabel "Number of neighbours"
set ylabel "Noise standard deviation"
set key Left top center
set grid
set yrange [*<0.9:1.1<*]
set ytics format "%.1f" 0.1
set mytics 2
set grid mytics

pl \
DATA using 1:(sqrt($2)) ps 2 title "No weights",\
1 lt -1 title "True value"
