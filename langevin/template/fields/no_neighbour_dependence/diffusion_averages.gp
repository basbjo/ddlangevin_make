#!/usr/bin/gnuplot

set terminal postscript eps color enhanced solid size 7cm,5cm
set output "diffusion_averages.eps"
#replot

gpmodel="../../../../model.gp"

DATA="diffusion_averages_noweights"

load gpmodel

set xlabel "Number of neighbours"
set ylabel "Diffusion average"
set key Left top center
set grid
set yrange [0:120]
set ytics format "%3.0f"

pl \
DATA notitle,\
DATA with yerror lt 1 title "No weights",\
60 lt -1 title "True value"
