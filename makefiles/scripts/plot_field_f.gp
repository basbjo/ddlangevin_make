#!/usr/bin/gnuplot

set terminal png
set output DATA.".png"
load gpmodel

set key top center out
set yrange [-600:600]
set grid

pl \
DATA using 1:($2/dt**2) notitle,\
DATA using 1:($2/dt**2):($3/dt**2) w e lt 1 title DATA,\
f(x) lt 2
