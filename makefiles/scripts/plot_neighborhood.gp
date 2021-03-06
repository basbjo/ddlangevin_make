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

current_x=sprintf("system('%s | grep \"Current point:\" | cut -d\\  -f3')",neighborhood)
current_y=sprintf("system('%s | grep \"Current point:\" | cut -d\\  -f4')",neighborhood)
double_epsilon=sprintf("system('%s | awk \" \
/Current point:/ { ndim=NF-2; for(i=3;i<=NF;i++) { x[i-2] = \\$i; } }; \
!/^#/ { cur_distance = 0; \
        for(i=1;i<=ndim;i++) { cur_distance += (x[i]-\\$(3*i-1))**2 }; \
        if(cur_distance > max_distance) { max_distance = cur_distance }; }; \
END { print 2*sqrt(max_distance) }\"')",neighborhood)

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
@neigbors using 2:5:($3-$2):($6-$5) w vector lc rgb "dark-green" notitle,\
@neigbors using 2:5 title "Neighbors",\
@neigbors using 3:6 title "Followers",\
@ncenter using 2:5 lt 6 lc 3 ps 2.5 title "Center",\
@current_point lt 1 ps 3 notitle

set print FILE.".box"
print sprintf("%.6g %.6g %.6g %.6g\n",GPVAL_X_MIN, GPVAL_X_MAX, GPVAL_Y_MIN, GPVAL_Y_MAX)
