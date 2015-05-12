#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output DATA.".tex"
if(!exists("LABEL")) LABEL=DATA
load gpmodel

set xlabel "Coordinate"
set ylabel "Effective number of neighbours"
set yrange [0:600]
set grid

pl \
DATA using 1:2 notitle,\
DATA using 1:2:($3*sqrt($4)) w e lt 1 title sprintf("\\verb|%s|",LABEL)
