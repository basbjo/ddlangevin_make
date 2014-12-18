#!/usr/bin/gnuplot
#Plots entries of eigenvectors

set terminal tikz standalone tightboundingbox
set output FILE.".tex"

set size square
set macros
plotcmd = "FILE matrix using (1+$1):(1+$2):($3**2) with image notitle"
labelcmd = "FILE matrix using (1+$1):(1+$2):(sprintf('%.2f',$3**2)) with labels notitle"
# labelcmd is used only if not more than 10 eigenvectors are shown
pl @plotcmd

set title sprintf('Squared eigenvector entries from \verb|%s|', FILE)
set xlabel "\\# eigenvector"
set ylabel "\\# entry of eigenvector"
if(!exists('xmax')) xmax=GPVAL_DATA_X_MAX-0.5
if(!exists('ymax')) ymax=GPVAL_DATA_Y_MAX-0.5
set xrange [GPVAL_DATA_X_MIN:xmax+0.5]
set yrange [GPVAL_DATA_Y_MIN:ymax+0.5]
if (xmax<5) set xtics 1
if (ymax<5) set ytics 1
set cbrange [0:1]

set output FILE.".tex"
if (xmax<=10) pl @plotcmd, @labelcmd
if (xmax>=11) pl @plotcmd
replot
