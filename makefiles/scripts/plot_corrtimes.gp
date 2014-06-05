#!/usr/local/bin/gnuplot
#Plots a table of correlation times

set terminal tikz standalone tightboundingbox
set output FILE.".tex"

if(!exists("SCALE")) SCALE=1
if(exists("UNIT")) in_units=sprintf(" [%s]", UNIT)
if(!exists("UNIT")) UNIT=""
if(exists("ymin")) set yrange [ymin:]
if(!exists("ymin")) ymin=0

REGEX = ".*-V([0-9]*).*tau = ([0-9.]+)( \\+/- )?([0-9.]+)?.* ([0-9]+)"
REPLACE = "\\1 \\2 \\4 \\5"
SEDSCR = sprintf("'s:%s:%s:'", REGEX, REPLACE)  # get right columns
LASCOL = "'s:.*-V([0-9]*).* ([0-9]+):\\1 \\2:'" # get last column
AWKSCR = sprintf("'{if (%g*$NF>%g) print $0}'", SCALE, ymin) # ignore values below ymin
DATA = sprintf("<sed -r %s %s | sort -k2 -gr | awk %s | sed 's/^0*//'", SEDSCR, FILE, AWKSCR)
LCOL = sprintf("<sed -r %s %s | sort -k2 -gr | awk %s | sed 's/^0*//'", LASCOL, FILE, AWKSCR)
set xlabel "Principal component"
set ylabel "Estimated correlation time".in_units
set log y
set grid
set key Left spacing 2
set title sprintf("Correlation times for \\verb|%s|", FILE)
plot \
    DATA u 0:(SCALE*$2) lt 1 title "Estimate from fit", \
    LCOL u 0:(SCALE*$2):xticlabels(1) lt 4 title "Time of decay to $e^{-1}$", \
    DATA u 0:(SCALE*$2):3 lt 1 w yerror notitle, \
    DATA u 0:(SCALE*$2):(sprintf("%d %s",SCALE*$2,UNIT)) \
         with labels offset graph +0.05,+0.11 rotate by 60 notitle, \
    LCOL u 0:(SCALE*$2):(sprintf("%d %s",SCALE*$2,UNIT)) \
         with labels offset graph -0.05,-0.11 rotate by 60 notitle
set xrange [-2+GPVAL_X_MIN:GPVAL_X_MAX+2]
if(!exists("ymax")) ymax = GPVAL_Y_MAX
set yrange [GPVAL_Y_MIN/6:ymax*12]
set output FILE.".tex"
replot
