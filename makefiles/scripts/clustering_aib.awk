#!/usr/bin/awk -f
#Geometric clustering for AIB in Ramachandran plot

# Usage:
# 	./cos_sin_tran.awk options file
# Options:
# 	-vmin_col=int: first column to be selected from source data
# 	-vmax_col=int: last column to be selected from source data

BEGIN {
	script="clustering.awk"
}
!/^#/ {
	sum = 1
	unknown = 0
	for(i=min_col;i<=max_col;i+=2)
	{
		if(($i+50)*($i+50)+($(i+1)+50)*($(i+1)+50)<1000)
		{
			color=1
		}
		else if(($i-50)*($i-50)+($(i+1)-50)*($(i+1)-50)<1000)
		{
			color=2
		}
		else
		{
			unknown = 1
		}
		sum += (color-1)*2**int((i-min_col)/2)
	}
	if (unknown == 0)
	{
	    print sum
	}
	else
	{
	    print 0
	}
	if(! (NR % 10000))
	{
		printf("\r%s: lines processed: %d", script, NR) > "/dev/stderr"
	}
}
END {
    if(NR>=10000) {
	    printf("\n") > "/dev/stderr"
    }
}
