#!/usr/bin/awk -f
#Select inner columns from min_col to max_col
#Output format is adapted to cos_sin_tran.awk

# Usage:
# 	./select_inner_columns.awk options file
# Options:
# 	-vmin_col=int: first column to be selected
# 	-vmax_col=int: last column to be selected

BEGIN {
	script="select_inner_columns.awk"
}
!/^#/ {
	for(i=min_col;i<=max_col;i++)
	{
		if (i>min_col)
		{
			printf("%s",OFS)
		}
		printf("%9f",$i)
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
