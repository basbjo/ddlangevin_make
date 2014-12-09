#!/usr/bin/gnuplot

set term png
set output "trajs.png"
set xlabel "Time frame"
set ylabel "Coordinate"
max = `ls splitdata/mle2_0.001ps-[0-9]*[0-9] | wc -l`
set multiplot layout 2,1
do for [i=1:max:max-1] {
pl sprintf('splitdata/mle2_0.001ps-%02d',i) u 1 w l title sprintf("Trajectory %d",i)
}
unset multiplot
