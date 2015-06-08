#!/usr/bin/gnuplot

#set terminal png size 520,390
set terminal tikz standalone tightboundingbox
set output OUTFILE

set title sprintf("Neighbourhood distances for\n\\verb|%s|",LABEL)
set key Left top center spacing 2
set log y
set ytics format "%.0e"
set grid

pl \
DATA1 using 1:2 notitle,\
DATA1 using 1:2:($3*sqrt($4)) w e lt 1 title "Distance to remotest neighbour",\
DATA2 using 1:2 notitle lt 2,\
DATA2 using 1:2:($3*sqrt($4)) w e lt 2 title "Distance to center of neighbours"
