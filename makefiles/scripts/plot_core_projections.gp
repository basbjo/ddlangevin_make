#!/usr/bin/gnuplot
#Plots core projections

if(!exists("CLUTRAJ")) CLUTRAJ=FILE.".coretraj"
if(!exists("V1")) V1=1
if(!exists("V2")) V2=2
colselect = sprintf("<awk '{print $%d,$%d}' %s",V1,V2,FILE)
cat = sprintf("| paste - %s",CLUTRAJ)
exclude_no_man_s_land = "| awk '{if($3!=0)print $0}'"

set terminal postscript eps color
set output sprintf("coreprojs_%s-V%02d-V%02d.eps",FILE,V1,V2)

set title sprintf("Clusters in %s",FILE)
set xlabel sprintf('V%d',V1)
set ylabel sprintf('V%d',V2)

pl colselect.cat.exclude_no_man_s_land u 1:2:3 w points palette pt 5 notitle
