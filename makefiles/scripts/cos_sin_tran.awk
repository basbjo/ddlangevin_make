#!/usr/bin/awk -f
#Select inner dihedrals and return cos/sin transform

# Usage:
# 	./cos_sin_tran.awk options file
# Options:
# 	-vmin_col=int: first column to be selected from source data
# 	-vmax_col=int: last column to be selected from source data

BEGIN {
	script="cos_sin_tran.awk"
	pi=3.14159265358979
}
!/^#/ {
	for(i=min_col;i<=max_col;i++)
	{
		printf("%s%9f%s%9f",OFS,cos($i*pi/180),OFS,sin($i*pi/180))
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
