#!/usr/bin/gawk -f
#Average all columns except the first and write out row wise

# Column labels are read from the first line starting with
# "#Content: " and are used as row labels in the print out.
# Only rows with a first column value between xmin and xmax
# are taken into account.
#
# Usage:
# 	./average_ltm.awk [options] file
# Options:
# 	-vxmin=num: minimum x value (default 0)
# 	-vxmax=num: maximum x value (default 100)
#       -vddof=num: delta degrees of freedom (default 1)
# Label line format:
#       "#Content: x_label col2_label..."
# Input line format:
# 	"x col2..."
# Output line format:
#        "col_label mean_col [stderr_of_mean_col]"

BEGIN {
	yfmt = "%.6e"
	if(xmin == "") { xmin = 0 }
	if(xmax == "") { xmax = 100 }
	if(ddof == "") { ddof = 1 }
}
/^#Content: / {
	ncols = NF-1
	for(col=1;col<=ncols;col++) {
		label[col] = $(col+1)
	}
}
!/^#/ {
	if ((xmin<=$1) && ($1<=xmax)) {
		for(col=2;col<=ncols;col++) {
			sum[col] += $col
			sumsq[col] += $col**2
			count[col] ++
		}
	}
}
END {
	print "#First label:", label[1]
	printf("#Interval: [%f:%f]\n",xmin,xmax)
	print "#Content: label mean stddev_of_mean number_of_values"
	for(col=2;col<=ncols;col++) {
		printf(label[col])
		printf(OFS OFMT, sum[col]/count[col])
		printf(OFS OFMT, sqrt((sumsq[col] - sum[col]**2/count[col])/(count[col]-ddof)))
		printf(OFS OFMT, count[col])
		printf("\n")
	}
}
