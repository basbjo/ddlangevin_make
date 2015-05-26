#!/usr/bin/gawk -f
#Calculates core centers and standard deviation

# Usage:
# 	./core_centers.awk [options] file
# Options:
# 	-vlast_col=int: last data column to be considered
#
# The file must contain integers to denote cores as last column.
# Points denoted by 0 are ignored (core numbering starts with 1).
#
# Output format:
# 	core mean1 stddev1 mean2 stddev2 ...

BEGIN {
	script="core_centers.awk"
}
!/^#/ {
	if ($NF>lastcluster)
	{
		lastcluster = $NF
	}
	if(last_col == "") { last_col = NF-1 }
	if ($NF>0)
	{
		for (i=1;i<=last_col;i++)
		{
			sum[$NF,i] += $i
			sumsq[$NF,i] += $i**2
		}
		count[$NF] += 1
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
    for (cluster=1;cluster<=lastcluster;cluster++)
    {
	if(count[cluster]>0)
	{
		printf("%i",cluster)
		for (i=1;i<=last_col;i++)
		{
			average = sum[cluster,i]/count[cluster]
			if(count[cluster]>1)
			{
				stddev = sqrt((sumsq[cluster,i]-count[cluster]*average**2)\
				       /(count[cluster]-1))
				printf(" %e %e",average,stddev)
			}
			else
			{
				printf(" %e nan",average)
			}
		}
		printf("\n")
	}
    }
}
