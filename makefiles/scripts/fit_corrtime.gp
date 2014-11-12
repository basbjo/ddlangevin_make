#!/usr/bin/gnuplot
#Estimates correlation time on [][exp(-1):1] by linear regression

set fit errorvariables
set fit logfile FITLOG
POINTSELECT=sprintf("<awk '!/^#/ {if($2<exp(-1))exit;print $0}' %s | sed 1d", FILE)

# fit
ymin = exp(-1)
f(x) = -x/tau - c
# ignore first value and values after zero-crossing
fit [][log(ymin):0] f(x) POINTSELECT u 1:(log($2)) via tau,c

# plotting
ymin = 0.35
xmax = -tau*(c + log(ymin))
set term png
set output PNG
set xrange [:xmax]
set yrange [ymin:1]
set log y
set ytics ("exp(-1)" exp(-1),0.4,0.5,0.6,0.7,0.8,0.9,1.0) format "%.1f"
set grid
set title "Fit for correlation time tau"
set xlabel "Time [time step]"
set ylabel "Normalized autocorrelation" offset 4
set label front right sprintf("tau = %g +/- %g",tau,tau_err) at graph 0.96,0.84
set label front right sprintf("c = %g", c) at graph 0.96,0.74
plot POINTSELECT title "", exp(f(x)) title "exp(-x/tau - c)"

# error and correlation time
print tau_err
print int(tau)
