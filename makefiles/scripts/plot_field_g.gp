#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output DATA.".tex"
if(!exists("LABEL")) LABEL=DATA
load gpmodel

set xlabel "Coordinate"
set ylabel "Friction average"
set yrange [0:2*Gamma0]
set key spacing 2
set grid

pl \
DATA using 1:(($2+1)/dt) lt 2 notitle,\
DATA using 1:(($2+1)/dt):($3*sqrt($4)/dt) with yerror lt 2 title sprintf("\\verb|%s|",LABEL),\
DATA using 1:(($2+1)/dt):($3/dt) with yerror lt 3 title "Standard deviation of mean values",\
Gamma(x) lt 1
