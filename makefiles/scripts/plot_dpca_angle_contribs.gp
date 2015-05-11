#!/usr/bin/gnuplot
#Plots average and maximal contributions of dihedral angles to PCs

#The plot shows the maximum contributions in green, the average
#contributions in blues and the average contributions normalized
#to sum total 1 in red.  The maximum contributions are the sums of
#squares of pairs of eigenvector entries corresponding to one angle.

set terminal pdf
set output OUTFILE
if(!exists('caption')) caption = FILE
if(!exists('ANGLES_PER_PLOT')) ANGLES_PER_PLOT = 20

# data
DATA_MAXIMUM(pc,bw) = sprintf('awk "{print \$%d}" %s | sed "N;s/\n/ /" | awk "{print NR, \$1**2 + \$2**2, %f}"', pc, EIGVEC, bw)
DATA_AVERAGE(pc,bw) = sprintf('grep "^%d " %s | awk "{print \$0, %f}"', pc, FILE, bw)

# settings
set xlabel "Dihedral angle"
set xtics 1 rotate by 45 right
set yrange [0:*<1]
set style fill solid 0.4
boxwidth1 = 0.2
boxwidth2 = 0.4

# plotting
NPCS = system(sprintf("head -n1 %s | wc -w", EIGVEC))
NANGLES = NPCS/2
PLOTS_PER_PC = (NANGLES+ANGLES_PER_PLOT-1)/ANGLES_PER_PLOT
do for [pc=1:NPCS] {
	sum = system(DATA_AVERAGE(pc,0)."| awk '{sum += $3}END{print sum}'")
	do for [pcplot=0:PLOTS_PER_PC-1] {
		set title sprintf("Mean contributions of dihedral angles to V%d from\n%s (plot %d/%d)", pc, caption, pcplot+1, PLOTS_PER_PC)
		plotfirstdih = pcplot*ANGLES_PER_PLOT + 1
		plotlastdih = (pcplot+1)*ANGLES_PER_PLOT
		if(PLOTS_PER_PC==1) {
			set title sprintf("Mean contributions of dihedral angles to V%d from\n%s", pc, caption)
			plotlastdih = NANGLES
		}
		set xrange [plotfirstdih-0.4+DIH_ANGLE_OFFSET:plotlastdih+0.6+DIH_ANGLE_OFFSET]
		pl '<'.DATA_AVERAGE(pc,boxwidth2) using ($2+DIH_ANGLE_OFFSET-0.1):($3/sum):5 with boxes title "Normalized Averages (sum total 1)",\
		   '<'.DATA_MAXIMUM(pc,boxwidth1) using ($1+DIH_ANGLE_OFFSET+0.2):2:3 with boxes title "Maxima (sum total 1)",\
		   '<'.DATA_AVERAGE(pc,boxwidth1) using ($2+DIH_ANGLE_OFFSET+0.4):3:5 with boxes title "Averages",\
		   '<'.DATA_AVERAGE(pc,0) using ($2+DIH_ANGLE_OFFSET-0.1):($3/sum):($4/sum) with yerrorbars linetype 1 notitle,\
		   '<'.DATA_AVERAGE(pc,0) using ($2+DIH_ANGLE_OFFSET+0.4):3:4 with yerrorbars linetype 1 lc 3 notitle
	}
}
