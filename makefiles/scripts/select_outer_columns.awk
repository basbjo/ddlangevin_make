#!/usr/bin/awk -f
#Select nfirst first and nlast last columns
#Output format is adapted to fastca output plus integer column

# Usage:
# 	./select_outer_columns.awk options file
# Options:
# 	-vnfirst=int: number of first columns to be selected
# 	-vnlast=int: number of last columns to be selected

BEGIN {
	script="select_outer_columns.awk"
}
!/^#/ {
	for (i=1;i<=nfirst;i++)
	{
		if (i>1)
		{
			printf("%s",OFS)
		}
		printf("%13e",$i)
	}
	if (NF-nlast<nfirst)
	{
		nlast = NF-nfirst
	}
	for (i=NF+1-nlast;i<=NF;i++) {
		printf(OFS OFMT,$(i))
	}
	printf("\n")
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
