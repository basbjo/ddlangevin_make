#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output OUTFILE
load gpmodel

set xlabel "Coordinate"
set ylabel "Diffusion average times noise standard deviation"
set yrange [0:120]
set grid

pl \
sprintf('<paste %s %s',DATA1,DATA2)\
 using 1:($2/dt**1.5*sqrt($7**2*$8)) notitle,\
sprintf('<paste %s %s',DATA1,DATA2)\
 using 1:($2/dt**1.5*sqrt($7**2*$8)):($3/dt**1.5*sqrt($7**2*$8))\
 with yerror lt 1 title sprintf("\\verb|%s|",LABEL),\
sqrt(2*kT*Gamma) lt 2
