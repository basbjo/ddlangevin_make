#!/usr/local/bin/gnuplot
#Plots correlation function from data and monoexponential decay

set output FILE.".png"
FILE = FILE.".cor"
set terminal png enhanced size 1280,480

if (!exists('TAU')) TAU = 1
set macros
func = sprintf('exp(-x/%g)', TAU)
FILE = sprintf('"%s"', FILE)

set ytics ("e^{-3}" exp(-3),0.1,"e^{-2}" exp(-2),0.2,0.3,"e^{-1}" exp(-1),0.4,0.5,0.6,0.7,0.8,0.9,1.0)
set ytics format "%.1f"
set grid
set xlabel "Number of time frames"

set multiplot layout 1,2
set yrange [0:1]
set ylabel "Normalized autocorrelation (lin scale)"
pl @FILE u 1:2:3 w yerror, @func, exp(-1) lt -1 title ""
set log y
set xrange [:3*TAU]
set yrange [exp(-3):1]
set ylabel "Normalized autocorrelation (log scale)"
replot
