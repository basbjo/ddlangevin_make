#!/usr/bin/gnuplot
#Plots core centers with ellipses of standard deviations

FILE = FILEROOT.'.corecenters'
if(!exists("V1")) V1=1
if(!exists("V2")) V2=2

set terminal tikz standalone tightboundingbox
set output sprintf("corecenters_%s-V%02d-V%02d.tex",FILEROOT,V1,V2)

set title sprintf("Clusters in \\verb|%s|",FILE)
set xlabel sprintf('V%d',V1)
set ylabel sprintf('V%d',V2)

set macros
use_ellipses = sprintf("%d:%d:(2*$%d):(2*$%d)",2*V1,2*V2,2*V1+1,2*V2+1)
use_labels = sprintf("%d:%d:1",2*V1,2*V2)
pl FILE u @use_ellipses with ellipses notitle,\
   FILE u @use_labels with labels notitle
