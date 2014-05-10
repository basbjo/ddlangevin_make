#!/usr/bin/awk -f
#Select nfirst first and nlast last columns
#Output format is adapted to fastca output plus integer column
!/^#/ {
	for (i=1;i<=nfirst;i++) {
		printf("%s%13e",OFS,$(i))
	}
	if (NF-nlast<nfirst) {
		nlast = NF-nfirst
	}
	for (i=NF+1-nlast;i<=NF;i++) {
		printf(OFS OFMT,$(i))
	}
	printf("\n")
}
