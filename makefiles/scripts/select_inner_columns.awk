#!/usr/bin/awk -f
#Select inner columns from dih_min_col to dih_max_col
#Output format is adapted to cos_sin_tran.awk

# Usage:
# 	./select_inner_columns.awk options file
# Options:
# 	-vdih_min_col=int: first column to be selected
# 	-vdih_max_col=int: last column to be selected

BEGIN {
	script="select_inner_columns.awk"
}
!/^#/ {
	for(i=dih_min_col;i<=dih_max_col;i++)
	{
		if (i>dih_min_col)
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
