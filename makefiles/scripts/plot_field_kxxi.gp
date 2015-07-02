#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output OUTFILE
load gpmodel

set xlabel "Coordinate"
set ylabel "Diffusion average times noise standard deviation"
set yrange [0:2*sqrt(2*kT*Gamma0)]
set key spacing 2
set grid

pl \
sprintf('<paste %s %s',DATA1,DATA2)\
 using 1:($2/dt**1.5*sqrt($7**2*$8)) lt 2 title sprintf("\\verb|%s|",LABEL),\
sprintf('<paste %s %s',DATA1,DATA2)\
 using 1:($2/dt**1.5*sqrt($7**2*$8)):($3*sqrt($4)/dt**1.5*sqrt($7**2*$8))\
 with yerror lt 2 title "Standard deviation of single values",\
sprintf('<paste %s %s',DATA1,DATA2)\
 using 1:($2/dt**1.5*sqrt($7**2*$8)):($3/dt**1.5*sqrt($7**2*$8))\
 with yerror lt 3 title "Standard deviation of mean values",\
sqrt(2*kT*Gamma(x)) lt 1 title "$\\sqrt{2\\,\\textrm{kT}\\;\\Gamma(x)}$"
