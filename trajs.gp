#!/usr/bin/gnuplot

set term png
set output "trajs.png"
set xlabel "Time frame"
set ylabel "Coordinate"
max = system(sprintf("ls splitdata/%s-[0-9]*[0-9] | wc -l",EXAMPLE))
set multiplot layout 2,1
do for [i=1:max:max-1] {
pl sprintf('splitdata/%s-%02d',EXAMPLE,i) u 1 w l title sprintf("Trajectory %d",i)
}
unset multiplot
