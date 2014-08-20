#!/bin/bash
#Create averaged autocorrelation file-V#.cor from file-##
#Uses av_second_column.py
#Uses logbinning.awk

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=6
DELIMITER=" "
BINS=100 # number of values in each data file (in fact it's BINS+1)

usage() {
    echo "
$SCRIPTNAME: Calculate averaged autocorrelation for one column

Usage: $0 name column fitdir splitprefix outdir program [options]
Arguments:
    - name:         filename root
    - column:       column number
    - fitdir:       directory with results from corrtime estimation
    - splitprefix:  split dir and name prefix to splitprefix-##
    - outdir:       directory for temporary files and result
    - program:      typically TISEAN corr with option -V0
    - options:      options that are passed to program

The range is set by the last line of »fitdir/name-V<column>.fit«.
The average of the correlations of »splitprefix-##« where
## = 01,02,... is written to »outdir/name-V<column>.cor«.
" >&2
    [ $NARGS -eq 1 ] && exit $1 || exit $EXIT_FAILURE
}

# get command line options
if [ "$1" = "-h" ]
then
    usage $EXIT_SUCCESS
fi

# missing arguments
if [ $NARGS -lt $NARGS_NEEDED ]
then
    usage $EXIT_ERROR
fi

# get command line arguments
scripts=$(dirname $0)
name=$1
column=$((10#$2)) # decimal representation forced, leading zeros removed
fitdir=$3
splitprefix=$4
outdir=$5
program=$6
shift ${NARGS_NEEDED}
options=$*
outfile=${outdir}/$(printf "%s-V%02d.cor" ${name} ${column})
fitfile=${fitdir}/$(printf "%s-V%02d.fit" ${name} ${column})
corrlength=$(tail -n1 ${fitfile})

# iterate trajectories
find -L $(dirname ${splitprefix}) -regex "[./]*${splitprefix}-[0-9]+" |
while read traj
do
    num=${traj##*-}
    echo "Calculate autocorrelation for ${name}, col ${column}, traj ${num}"
    if [ "${corrlength}" == "" ] || [ ${corrlength} -lt ${BINS} ]
    then
        # minimum correlation length is number of bins
        corrlength=${BINS}
    fi
    # call TISEAN corr and do binning on the fly
    eval "${program} ${options} -c${column} -D${corrlength} ${traj} \
      | ${scripts}/logbinning.awk -vxmin=1 -vxmax=${corrlength} -vbins=${BINS} \
      > ${outfile}.tmp${num}"
done || exit $EXIT_ERROR

# average
echo "Calculate autocorrelation for ${name}, col ${column}, average"
${scripts}/av_second_column.py ${outfile}.tmp[0-9]*[0-9] > ${outfile} &&
    find -type f -regex "[./]*${outfile}.tmp[0-9]+" -delete

exit $EXIT_SUCCESS
