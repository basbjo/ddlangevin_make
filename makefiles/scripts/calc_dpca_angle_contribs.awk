#!/usr/bin/gawk -f
#Calculates average contributions of dihedral angles to PCs

# Usage:
# 	./calc_dpca_angle_contribs.awk eigvec_file cossin_file
# Input eigvec_file format (quadratic array):
# 	"e_{11} e_{21} ..."
#       "e_{12} e_{22} ..."
#       "..."
# Input cossin_file line format (no comment lines or blank lines):
#       "cos(a1) sin(a1) cos(a2) sin(a2) ...
# Output line format:
#        "pc angle mean(w) std(w)"

# Given n dihedral angles a_j, we define the cosine- and sine-transformed
# data component wise by x_{2j-1} = cos(a_j) and x_{2j} = sin(a_j).  Let
# the i'th principal component (PC)
#
#   z_i = sum_{j=1}^{2n} x_j e_{ij} .
#
# This program then calculates the quadratically weighted contributions
#
#  w_{ij} = [\partial z_i / \partial a_j]^2
#         = [-e_{i,2j-1}*sin(a_j) + e_{i,2j}*cos(a_j)]^2
#
# and averages them over all rows in cossin_file.

BEGIN {
	script="calc_dpca_angle_contribs.awk"
	ncols = 0;
	nrow = 0;
	ddof = 1;
	OFMT = "%e";
}
!/^#/ {
	if (NR == FNR) {
		# read eigenvectors from file 1
		if (ncols == 0) {
			ncols = NF;
		}
		nrow++;
		for (pc=1;pc<=ncols;pc++) {
			eigvec[pc][nrow] = $pc;
		}
	}
	else {
		# sum up contributions of all samples in file 2
		if (nrow != ncols) {
			print "ERROR:", FILENAME, "must have the same number of rows and columns!" > "/dev/stderr";
			exit 1;
		}
		for (pc=1;pc<=ncols;pc++) {
			for (ii=2;ii<=ncols;ii+=2) {
				angle = ii/2;
				cosine = $(ii-1);
				sine = $(ii);
				sum[pc][angle] += (-eigvec[pc][ii-1]*sine + eigvec[pc][ii]*cosine)**2;
				sumsq[pc][angle] += (-eigvec[pc][ii-1]*sine + eigvec[pc][ii]*cosine)**4;
			}
		}
	}
	if(! (NR % 1000))
	{
		printf("\r%s: lines processed: %d", script, NR) > "/dev/stderr"
	}
}
END {
    if(NR>=1000) {
	    printf("\n") > "/dev/stderr"
    }
	if (NR == FNR) {
		print "ERROR: second input file is missing or empty!" > "/dev/stderr";
		exit 1;
	}
	else {
		# print results (pc number, averages and standard deviations)
		for (pc=1;pc<=ncols;pc++) {
			for (angle=1;2*angle<=ncols;angle++) {
			}
			for (angle=1;2*angle<=ncols;angle++) {
				printf("%d %d", pc, angle);
				printf(" " OFMT, sum[pc][angle]/FNR);
				printf(" " OFMT, sqrt((sumsq[pc][angle] - sum[pc][angle]**2/FNR)/(FNR-ddof)));
				printf("\n");
			}
			printf("\n");
		}
	}
}
