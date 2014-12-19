#!/usr/bin/gnuplot

set terminal png size 520,390
set output DATA.".png"
load gpmodel

set xlabel "Coordinate"
set ylabel "Drift average"
set yrange [-600:600]
set grid

pl \
DATA using 1:($2/dt**2) notitle,\
DATA using 1:($2/dt**2):($3/dt**2) w e lt 1 title DATA,\
f(x) lt 2
