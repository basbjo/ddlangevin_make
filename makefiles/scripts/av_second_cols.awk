#!/usr/bin/awk -f
#Average every second column and print first column, mean and stddev
#Input format: x y1 x y2...
BEGIN {
	print "#averaged data series"
	print "#format: x y_mean stddev_of_mean"
}
!/^#/ {
	sum=0
	sumsqr=0
	for(j=2;j<=NF;j+=2)
	{
		sum += $(j)
		sumsqr += $(j)*$(j)
	}
	N = int(NF/2)
	variance = (sumsqr - sum*sum/N)/(N-1)
	print $1, sum/N, sqrt(variance)/sqrt(N)
}
