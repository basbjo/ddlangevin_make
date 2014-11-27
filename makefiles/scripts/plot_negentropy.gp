#!/usr/bin/gnuplot
#Plots a table of negentropies

set terminal tikz standalone tightboundingbox
set output FILE.".tex"

set title sprintf("Negentropies for \\verb|%s|", FILE)
set xlabel "Component"
set ylabel "Negentropy"
set xtics 1
set grid y
plot FILE using 1:2 with boxes notitle
set xrange [0.5:GPVAL_X_MAX-0.5]
set yrange [0:]
set output FILE.".tex"
replot
