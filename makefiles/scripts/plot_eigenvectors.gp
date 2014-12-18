#!/usr/bin/gnuplot
#Plots entries of eigenvectors

set terminal tikz standalone tightboundingbox
set output FILE.".tex"

set xtics 1
set ytics 1
pl FILE matrix using (1+$1):(1+$2):($3**2) with image notitle

set title sprintf('Squared eigenvector entries from \verb|%s|', FILE)
set xlabel "\\# eigenvector"
set ylabel "\\# entry of eigenvector"
if(!exists('lastcol')) set xrange [GPVAL_DATA_X_MIN:GPVAL_DATA_X_MAX]
if(exists('lastcol')) set xrange [GPVAL_DATA_X_MIN:lastcol+0.5]
if(!exists('lastcol')) set yrange [GPVAL_DATA_Y_MIN:GPVAL_DATA_Y_MAX]
if(exists('lastcol')) set yrange [GPVAL_DATA_Y_MIN:lastcol+0.5]
set cbrange [0:1]

set output FILE.".tex"
replot
