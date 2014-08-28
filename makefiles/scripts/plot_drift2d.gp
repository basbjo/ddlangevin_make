#!/usr/bin/gnuplot
#Plot 2d drift field

suffix = '.2ddrifthist'
# omit arrows longer than range/cutdivisor
cutdivisor = 10
# factor to guess appropriate scaling
scalefactor = 0.5/std

# newline after filename unit in title
set macros
sedscr = "'s/(_[0-9]+[A-Za-z]+)\.?/\\1|\\\\n\\\\\\\\verb|/'"
titlemacro = sprintf('"`echo %s | sed -r %s`"', name, sedscr)
titlestring = sprintf("Drift field for \\verb|%s|", @titlemacro)

# settings
set title titlestring
set size square
unset colorbox
AWKSCR = sprintf("<awk '{%%sprint $0,sqrt(($3*$3)+($4*$4))}' %s/%s%s",\
							dir, name, suffix)

# temporary plot to get range information
set terminal png
set output sprintf("/dev/null", name)
scale = 1
plot sprintf(AWKSCR, '') u 1:2:(-$3*scale):(-$4*scale):5\
	w vectors filled lc palette notitle

# plot with adjusted scaling
set output sprintf("%s/drift2d_%s.png", dir, name)
scale = scalefactor/sqrt(GPVAL_X_MAX**2 + GPVAL_Y_MAX**2)
set label 1 at graph 1.05,0.5 center rotate by 90
set label 1 sprintf("arrow scale = %f", scale)
replot

# plot with same scaling and cut arrow lengths
set terminal tikz standalone tightboundingbox gparrows scale 1.4,1.4
set output sprintf("drift2d_%s.tex", name)
xsqmax = ((GPVAL_X_MAX-GPVAL_X_MIN)/scale/cutdivisor)**2
ysqmax = ((GPVAL_Y_MAX-GPVAL_Y_MIN)/scale/cutdivisor)**2
AWKCUT = sprintf('if(($3*$3<%f)&&($4*$4<%f)&&($3*$3+$4*$4>0))', xsqmax, ysqmax)
plot sprintf(AWKSCR, AWKCUT) u 1:2:(-$3*scale):(-$4*scale):(-log($5))\
	w vectors filled lc palette notitle

