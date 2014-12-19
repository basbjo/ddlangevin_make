#!/usr/bin/gnuplot

set terminal png size 520,390
set output DATA.".png"
load gpmodel

set xlabel "Coordinate"
set ylabel "Diffusion average"
set yrange [0:120]
set grid

pl \
DATA using 1:($2/dt**1.5) notitle,\
DATA using 1:($2/dt**1.5):($3/dt**1.5) w e lt 1 title DATA,\
sqrt(2*kT*Gamma) lt 2
