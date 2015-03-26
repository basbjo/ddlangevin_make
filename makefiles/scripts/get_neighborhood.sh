#!/bin/bash
#Print out coordinates of a single neighborhood using an ol-search-neighbors index file

#WARNING: Currently ndim=2 and before changing this
#         the ugly hack in neigbour_indices() needs
#         to be amended.

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=2

usage() {
    echo "
$SCRIPTNAME: Prints out coordinates of a single neighborhood

Usage: $0 pointfile osnfile [osnfilerow]
Options:
    -h          display these options
    -o str      option with string argument
    -n          option without argument
Arguments:
    - pointfile:    Input file of ol-search-neighbors
    - osnfile:      Output file of ol-search-neighbors
    - osnfilerow:   Row to select from osnfile (default 1)

An osnfile contains points and indices of neighbors on each row.
" >&2
    [ $NARGS -eq 1 ] && exit $1 || exit $EXIT_FAILURE
}

# get command line options

# missing arguments
if [ $NARGS -lt $NARGS_NEEDED ]
then
    usage $EXIT_ERROR
fi

# get command line arguments
scripts=$(dirname $0)
pointfile=$1
osnfile=$2

if [ $NARGS -gt $NARGS_NEEDED ]
then
    osnfilerow=$3
else
    osnfilerow=1
fi

# select one line from ol-search-neighbor output
function pointselect() {
     grep -v '^#' ${osnfile} | head -n${osnfilerow} | tail -n1
}

# create sorted list of indices of neighbors
function neigbour_indices() {
    tr ' ' '\n' \
        | sed '1s/^/1-/' \
        | sed '2s/^/2-/' \
        | grep -v '^$' | sort -n \
        | sed 's/^[12]-//'
}

# extract neighbor coordinates from pointfile and print results
pointselect \
| neigbour_indices \
| awk '
BEGIN{
    print "#Content: x1_{n} x2_{n} x1_{n+1} x2_{n+1} n";
    row=1;
    ndim=2;
    nind=ndim;
    OFMT="%.6e";
};
!/^#/ {
    # Print current point
    if(NR==1) {
        printf("#Current point:");
    }
    if(NR<=ndim) {
        printf(" " OFMT,$1);
    }
    if(NR==ndim) {
        printf("\n");
    }
    # Print neighbors
    if(FNR==NR) {
        ind[NR-1] = $1;
    } else {
        if(ind[nind]+1 == row) {
            for(i=1;i<=ndim;i++) {
                printf(OFMT " ",lastx[i]);
            }
            for(i=1;i<=ndim;i++) {
                printf(OFMT " ",$i);
            }
            printf("%d\n",ind[nind]);
            nind++;
        };
        for(i=1;i<=ndim;i++) {
            lastx[i]=$i;
        }
        row++;
    }
}' - ${pointfile}

exit $EXIT_SUCCESS
