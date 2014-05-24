#!/usr/bin/gawk -f
#Binning of data by averaging x and y values (e.g. for TISEAN corr output)

# The minimum x value if it is taken is printed separately
# Comment lines starting with # are just printed out
#
# Usage:
# 	./binning.awk [options] file
# Options:
# 	-vbins=int: number of bins (default 100)
# 	-vxmin=num: minimum x value (default 0)
# 	-vxmax=num: maximum x value (default 100)
# 	-vstep=num: x step (default 1)
# 	-verror=1:  if set, average errors in third column
# Input line format:
# 	"x y [y_err]"
# Output line format:
#        "mean_x mean_y [stderr_of_mean_y]"

BEGIN {
	yfmt = "%.6e"
	if(bins == "") { bins = 100 }
	if(xmin == "") { xmin = 0 }
	if(xmax == "") { xmax = 100 }
	if(step == "") { step = 1 }
	range = xmax-xmin
}
/^#/ {
	print $0
}
!/^#/ {
	ind = int( 1+($1-xmin-step)*bins/range )
	count[ind] ++
	sum_x[ind] += $1
	sum_y[ind] += $2
	if(error==1) { sumsq_y_err[ind] += $3**2 }
}
END {
	for(i=0;i<=bins;i++) {
		if(count[i]>0) {
			printf(OFMT, sum_x[i]/count[i])
			printf(OFS)
			printf(yfmt, sum_y[i]/count[i])
			if(error==1) {
				printf(OFS)
				printf(OFMT, sqrt(sumsq_y_err[i])/count[i])
			}
			printf("\n")
		}
	}
}
