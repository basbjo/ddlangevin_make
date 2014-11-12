#!/usr/bin/gnuplot
#Plot ratios between decreasing correlation times from table *.tau

OUTFILE=FILE.".ratios.tex"

set terminal tikz standalone tightboundingbox
set output OUTFILE

set macros
if(exists("ymax")) AWKMAX=sprintf("'{if($2>%f) print $1, 2*%f; else print $0}'",ymax,ymax)

SEDSCR = "'s/.*-V0*\\([0-9]*\\).cor: \\(.*\\)/\\1 \\2/'"
AWKSCR = "'{if (lastcol != 0) { print lastcol \"$\\\\\\\\rightarrow$\" $1, lasttime/$2 }; lastcol=$1; lasttime=$2}'"
DATA = sprintf("<sed %s %s | gawk %s", SEDSCR, FILE, AWKSCR)
if(exists("AWKMAX")) DATA = DATA." | gawk ".AWKMAX
set title sprintf("Ratios between decreasing correlation times\nfor \\verb|%s|", FILE)
set xlabel "Principal components" offset graph 0,-0.05
set xtics right rotate by 60 offset 0.4,0.2
set xtics nomirror
set x2tics 1,1
set grid
set key Left spacing 2
plot \
    DATA u ($0+1):2:xticlabels(1) lt 1 notitle, \
    DATA u ($0+1):2:x2ticlabels(sprintf("%d",$0+1)) lt 1 notitle, \
    DATA u ($0+1):2:(sprintf("%.1f",$2)) \
         with labels offset graph 0,0.05 notitle
set xrange [-1+GPVAL_X_MIN:GPVAL_X_MAX+1]
if(!exists("ymax")) ymax = GPVAL_Y_MAX
set yrange [GPVAL_Y_MIN/6:ymax*1.1]
set output OUTFILE
replot
