#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output OUTFILE
load gpmodel

set xlabel "Coordinate"
set ylabel "Friction average times noise variance"
set yrange [0:2*Gamma0]
set grid

pl \
sprintf('<paste %s %s',DATA1,DATA2)\
 using 1:(($2+1)/dt*$7**2*$8) notitle,\
sprintf('<paste %s %s',DATA1,DATA2)\
 using 1:(($2+1)/dt*$7**2*$8):($3*sqrt($4)/dt*$7**2*$8)\
 with yerror lt 1 title sprintf("\\verb|%s|",LABEL),\
Gamma(x) lt 2
