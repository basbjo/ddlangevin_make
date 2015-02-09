#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output DATA.".tex"
if(!exists("LABEL")) LABEL=DATA
load gpmodel

set xlabel "Coordinate"
set ylabel "Drift average"
set yrange [-300:300]
set grid

pl \
DATA using 1:($2/dt**2) notitle,\
DATA using 1:($2/dt**2):($3/dt**2) w e lt 1 title sprintf("\\verb|%s|",LABEL),\
f(x) lt 2
