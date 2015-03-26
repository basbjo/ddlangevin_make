#!/usr/bin/gnuplot
#Plots a two dimensional neighborhood with followers

set terminal tikz standalone tightboundingbox gparrows solid
set output FILE.".tex"

# newline after filename unit in title
set macros
sedscr = "'s/(_[0-9.]+[A-Za-z]+)\.?/\\1|\\\\n\\\\\\\\verb|/'"
titlemacro = sprintf('"`echo %s | sed -r %s`"', FILE, sedscr)
titlestring = sprintf("Neighborhood \\verb|%s|", @titlemacro)

# data
neighborhood=sprintf("cat %s.nh",FILE)
neigbors=sprintf("'<%s'",neighborhood)
ncenter=sprintf("'<%s | bmdmean'",neighborhood)
current_point=sprintf("'<%s | grep \"Current point:\" | sed \"s/.*: //\"'",neighborhood)

current_x=sprintf("system('%s | grep \"Current point:\" | sed \"s/.*: //;s/ .*//\"')",neighborhood)
current_y=sprintf("system('%s | grep \"Current point:\" | sed \"s/.*: //;s/.* //\"')",neighborhood)
double_epsilon=sprintf("system('%s | awk \"/Current point:/{x=\\$3; y=\\$4}; !/^#/{print 2*sqrt((x-\\$1)**2 + (y-\\$2)**2)}\" | bmdmax')",neighborhood)

# settings
set title titlestring
set size square
set key bottom center out horizontal
set grid

set pointsize 1.5

# center of neighbors
set object 1 ellipse at @current_x,@current_y size @double_epsilon,@double_epsilon behind fillcolor rgb "gray"

# plot
plot\
@current_point title "Current point",\
@neigbors using 1:2:($3-$1):($4-$2) w vector lc rgb "dark-green" notitle,\
@neigbors using 1:2 title "Neighbors",\
@neigbors using 3:4 title "Followers",\
@ncenter using 1:2 lt 6 lc 3 ps 2.5 title "Center",\
@current_point lt 1 ps 3 notitle

set print FILE.".box"
print sprintf("%.6g %.6g %.6g %.6g\n",GPVAL_X_MIN, GPVAL_X_MAX, GPVAL_Y_MIN, GPVAL_Y_MAX)
