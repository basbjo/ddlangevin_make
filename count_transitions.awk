#!/usr/bin/gawk -f
{
	if(sqrt($1**2)>3 && $1*last<=0) {
		last=$1
		count++
	}
}
END {
	print count-1
}
