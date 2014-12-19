#!/usr/bin/gnuplot

set terminal png size 520,390
set output DATA.".png"
load gpmodel

set xlabel "Coordinate"
set ylabel "Friction average"
set yrange [0:2*Gamma]
set grid

pl \
DATA using 1:(($2+1)/dt) notitle,\
DATA using 1:(($2+1)/dt):($3/dt) w e lt 1 title DATA,\
Gamma lt 2
