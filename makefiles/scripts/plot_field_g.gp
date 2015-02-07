#!/usr/bin/gnuplot

set terminal png
set output DATA.".png"
load gpmodel

set key top center out
set yrange [0:2*Gamma]
set grid

pl \
DATA using 1:(($2+1)/dt) notitle,\
DATA using 1:(($2+1)/dt):($3/dt) w e lt 1 title DATA,\
Gamma lt 2
