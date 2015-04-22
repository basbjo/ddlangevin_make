#!/usr/bin/gnuplot
#Plots neighborhood positions in 2D histogram

set terminal pdf
set output FILE.".pdf"

# newline after filename unit in title
set macros
sedscr = "'s/(_[0-9.]+[A-Za-z]+)\.?/\\1\\\\n\\\\/'"
titlemacro = sprintf('"`echo %s | sed -r %s`"', FILE, sedscr)
titlestring = sprintf("Neighborhood positions for %s", @titlemacro)

maxvalue = system(sprintf("bmdmax %s 2>/dev/null|cut -f5",HIST2D))
hist2dcrop = sprintf("<awk '{if ($5<%s) print $0}' %s",maxvalue,HIST2D)
inlay_positions = sprintf("<grep . %s.row*.box | sed 's/.*.row//;s/\.box:/ /'",FILE)

set title titlestring
set size square
set pointsize 0.3

pl hist2dcrop u 1:2:5 w points pt 5 palette notitle, \
inlay_positions using 2:3:2:3:4:5 with boxxyerrorbars lc rgb "lightgray" notitle,\
inlay_positions using (0.5*($2+$3)):(0.5*($4+$5)):1 with labels notitle
