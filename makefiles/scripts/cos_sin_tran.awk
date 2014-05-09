#!/usr/bin/awk -f
#Select inner dihedrals and return cos/sin transform
BEGIN {
	pi=3.14159265358979
}
!/^#/ {
	for(i=dih_min_col;i<=dih_max_col;i++)
	{
		printf("%s%9f%s%9f",OFS,cos($i*pi/180),OFS,sin($i*pi/180))
	}
	printf("\n")
}
