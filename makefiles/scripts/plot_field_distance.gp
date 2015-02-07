#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output DATA.".tex"
load gpmodel

set xlabel "Coordinate"
set ylabel "Distance to remotest neighbour"
set log y
set ytics format "%.0e"
set grid

pl \
DATA using 1:2 notitle,\
DATA using 1:2:3 w e lt 1 title sprintf("\\verb|%s|",DATA)
