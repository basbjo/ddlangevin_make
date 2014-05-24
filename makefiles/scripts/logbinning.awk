#!/usr/bin/gawk -f
#Logarithmic binning of data by averaging x and y values (e.g. for TISEAN corr output)

# The minimum x value if it is taken is printed separately
# Comment lines starting with # are just printed out
#
# Usage:
# 	./logbinning.awk [options] file
# Options:
# 	-vbins=int: number of bins (default 100)
# 	-vxmin=num: minimum x value (default 1)
# 	-vxmax=num: maximum x value (default 100)
# 	-verror=1:  if set, average errors in third column
# Input line format:
# 	"x y [y_err]" with positive x
# Output line format:
#        "mean_x mean_y [stderr_of_mean_y]"
#
# For non integer x the final number of values may be less than bins

BEGIN {
	yfmt = "%.6e"
	if(bins == 0) { bins = 100 }
	if(xmin == 0) { xmin = 1 }
	if(xmax == 0) { xmax = 100 }

	range = log(xmax)-log(xmin)

	# iteratively determine number of pseudo bins needed to get bins values
	pbins = bins
	toofew = 1
	while (toofew>0) {
		# before first there are empty bins
		first = 1/(1-exp(-range*pbins**-1))
		# the number of these empty bins is
		toofew = int(((log(first)-log(xmin))*(pbins)/range)-first)
		# there may be more empty bins at the end
		toofew += bins-int((log(xmax)-log(xmin))*(pbins)/range)
		pbins += toofew
	}
}
/^#/ {
	print $0
}
!/^#/ {if($1>0) {
	ind = int( (log($1)-log(xmin))*pbins/range )
	count[ind] ++
	sum_x[ind] += $1
	sum_y[ind] += $2
	if(error==1) { sumsq_y_err[ind] += $3**2 }
}}
END {
	for(i=0;i<=pbins;i++) {
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
