#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output DATA.".tex"
if(!exists("LABEL")) LABEL=DATA

set xlabel "Coordinate"
set ylabel "Ratio $\\langle(x_{n} - y_{m})^2\\rangle / \\langle(x_{n-1} - y_{m})^2\\rangle$"
set yrange [0:]
set key spacing 2
set grid
set format y "%.1e"

pl \
DATA using 1:2 lt 2  title sprintf("\\verb|%s|",LABEL),\
DATA using 1:2:($3*sqrt($4)) with yerror lt 2 title "Standard deviation of single values",\
DATA using 1:2:($3) with yerrorlines lt 1 lc 3 title "Standard deviation of mean values"
