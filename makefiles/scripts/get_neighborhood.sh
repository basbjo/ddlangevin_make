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

Usage: $0 pointfile osnfile [osnfilerow] [ndim]
Arguments:
    - pointfile:    Input file of ol-search-neighbors
    - osnfile:      Output file of ol-search-neighbors
    - osnfilerow:   Row to select from osnfile (default 1)
    - ndim:         Number of components (default 2)

An osnfile contains ndim components of points followed
by indices of the corresponding neighbors on each row.
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

if [ $NARGS -ge 3 ]
then
    osnfilerow=$3
else
    osnfilerow=1
fi

if [ $NARGS -eq 4 ]
then
    ndim=$4
else
    ndim=2
fi

# select one line from ol-search-neighbors output
function pointselect() {
     grep -v '^#' ${osnfile} | head -n${osnfilerow} | tail -n1
}

# create sorted list of indices of neighbors
function neigbour_indices() {
    tr ' ' '\n' \
        | awk -vndim=${ndim} '{if (NR<=ndim) {print "NR" NR "=" $0} else {print $0}}' \
        | grep -v '^$' | sort -n \
        | sed 's/^NR[0-9][0-9]*=//'
}

# extract neighbor coordinates from pointfile and print results
pointselect \
| neigbour_indices \
| awk -v ndim=${ndim} '
BEGIN{
    row=1;
    nind=ndim;
    OFMT="%.6e";
    printf("#Content:");
    for(i=1;i<=ndim;i++) {
        printf(" x%d_{n-1}",i);
        printf(" x%d_{n}",i);
        printf(" x%d_{n+1}",i);
    }
    printf(" n\n");
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
                if(ind[nind] == 1) {
                    # if predeccessor is missing
                    printf("nan ");
                } else {
                    printf(OFMT " ",lastpred[i]);
                }
                printf(OFMT " ",lastx[i]);
                printf(OFMT " ",$i);
            }
            printf("%d\n",ind[nind]);
            nind++;
        };
        for(i=1;i<=ndim;i++) {
            lastpred[i] = lastx[i]
            lastx[i]=$i;
        }
        row++;
    }
}
END {
    if(ind[nind]+1 == row) {
        # print point if successor is missing
        for(i=1;i<=ndim;i++) {
            printf(OFMT " ",lastpred[i]);
            printf(OFMT " ",lastx[i]);
            printf("nan ");
        }
        printf("%d\n",ind[nind]);
    }
}' - ${pointfile}

exit $EXIT_SUCCESS
