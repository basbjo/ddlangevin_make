#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output DATA.".tex"
if(!exists("LABEL")) LABEL=DATA
load gpmodel

set xlabel "Coordinate"
set ylabel "Drift average"
set yrange [-300:300]
set key spacing 2
set grid

pl \
DATA using 1:($2/dt**2) lt 2 title sprintf("\\verb|%s|",LABEL),\
DATA using 1:($2/dt**2):($3*sqrt($4)/dt**2) with yerror lt 2 title "Standard deviation of single values",\
DATA using 1:($2/dt**2):($3/dt**2) with yerror lt 3 title "Standard deviation of mean values",\
f(x) lt 1 title "$f(x)$"
