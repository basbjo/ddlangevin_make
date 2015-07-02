#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output DATA.".tex"
if(!exists("LABEL")) LABEL=DATA
load gpmodel

set xlabel "Coordinate"
set ylabel "Diffusion average"
set yrange [0:2*sqrt(2*kT*Gamma0)]
set key spacing 2
set grid

pl \
DATA using 1:($2/dt**1.5) lt 2 title sprintf("\\verb|%s|",LABEL),\
DATA using 1:($2/dt**1.5):($3*sqrt($4)/dt**1.5) with yerror lt 2 title "Standard deviation of single values",\
DATA using 1:($2/dt**1.5):($3/dt**1.5) with yerror lt 3 title "Standard deviation of mean values",\
sqrt(2*kT*Gamma(x)) lt 1 title "$\\sqrt{2\\,\\textrm{kT}\\;\\Gamma(x)}$"
