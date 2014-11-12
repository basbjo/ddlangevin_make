#!/usr/bin/gnuplot
#Plots a table of correlation times

set terminal tikz standalone tightboundingbox
set output FILE.".tex"

in_units=""
if(exists("UNIT")) in_units=sprintf(" [%s]", UNIT)
if(!exists("UNIT")) UNIT=""
if(!exists("SCALE")) SCALE=1
if(exists("ymin")) set yrange [ymin:]
if(!exists("ymin")) ymin=1

SEDSCR = "'s/.*-V0*//;s/\.cor://'"
AWKSCR = sprintf("'{if (%g*$NF>%g) print $0}'", SCALE, ymin) # ignore values below ymin
DATA = sprintf("<sed -r %s %s | awk %s", SEDSCR, FILE, AWKSCR)
set xlabel "Principal component"
set ylabel "Time of decay to $e^{-1}$".in_units
set x2tics
set log y
set grid
set key Left spacing 2
set title sprintf("Correlation times for \\verb|%s|", FILE)
plot \
    SCALE*LAG lc 5 title sprintf("Lag time %g%s",LAG*SCALE,UNIT), \
    DATA u ($0+1):(SCALE*$2):(SCALE*$3):(SCALE*$4) w e lt 1 notitle, \
    DATA u ($0+1):(SCALE*$2):xticlabels(1) lt 1 notitle, \
    DATA u ($0+1):(SCALE*$2):x2ticlabels(sprintf("%d",$0+1)) lt 1 notitle, \
    DATA u ($0+1):(SCALE*$2):(sprintf("%d %s",SCALE*$2,UNIT)) \
         with labels offset graph -0.04,-0.1 rotate by 60 notitle
set xrange [-2+GPVAL_X_MIN:GPVAL_X_MAX+1]
if(!exists("ymax")) ymax = GPVAL_Y_MAX
set yrange [GPVAL_Y_MIN/6:ymax]
set output FILE.".tex"
replot
