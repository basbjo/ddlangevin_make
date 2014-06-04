#!/usr/bin/gawk -f
#Get time of decay to exp(-1) with errors

# Takes the mean of the two x values around y=exp(-1).
# If the first y-value is below exp(-1), the mean
# between the first x-value and zero is used instead.
# For xmin and xmax, y-y_err and y+y_err are used for y.
#
# Usage:
# 	./binning.awk file
# Input line format:
# 	"x y y_err"
# Output line format:
#        "x xmin xmax"

!/^#/{
	# values for x
	if (next_x == "") {
		if($2<exp(-1)) {
			next_x = $1
		}
		else {
			last_x = $1
		}
	}
	# values for xmin
	if (next_xmin == "") {
		if($2-$3<exp(-1)) {
			next_xmin = $1
		}
		else {
			last_xmin = $1
		}
	}
	# values for xmax
	if (next_xmax == "") {
		if($2+$3<exp(-1)) {
			next_xmax = $1
		}
		else {
			last_xmax = $1
		}
	}
}
END {
	print (last_x+next_x)/2, (last_xmin+next_xmin)/2, (last_xmax+next_xmax)/2
}
