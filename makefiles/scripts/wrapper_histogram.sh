#!/bin/bash
#Calculate averaged 1D histogram file-V#.hist from file-##
#Uses av_second_column.py

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=6

usage() {
    echo "
$SCRIPTNAME: Calculate averaged 1D histogram for one column

Usage: $0 name column minmax splitprefix outdir program [options]
Arguments:
    - name:         outfilename root
    - column:       column number
    - minmax:       reference file with minima and maxima or \"\",
                    must contain two lines with minima and maxima
    - splitprefix:  split dir and name prefix to splitprefix-##
    - outdir:       directory for temporary files and result
    - program:      typically TISEAN histogram with option -V0
    - options:      options that are passed to program

The minimum range is set by concatenating minmax to input.
The average of the histograms of »splitprefix-##« where
## = 01,02,... is written to »outdir/name-V<column>.hist«.
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
minmax=$3
splitprefix=$4
outdir=$5
program=$6
shift ${NARGS_NEEDED}
options=$*
outfile=${outdir}/$(printf "%s-V%02d.hist" ${name} ${column})

# test histogram version (need patch with option -r)
${program} -h 2>&1 | grep -q -- '-r reference file for binning' || {
    echo "Wrong histogram version! Option '-r' needed." >&2
    exit $EXIT_ERROR
}

# iterate trajectories
find -L $(dirname ${splitprefix}) -regex "[./]*${splitprefix}-[0-9]+" |
while read traj
do
    num=${traj##*-}
    echo "Calculate histogram for ${name}, col ${column}, traj ${num}"
    if [ -z "${minmax}" ]
    then
        ${program} -c${column} ${options} ${traj} -o ${outfile}.tmp${num}
    elif [ -f ${minmax} ] && [ $(wc -l ${minmax}|awk '{print $1}') -eq 2 ]
    then
        ${program} -c${column} ${options} -r ${minmax} ${traj} -o ${outfile}.tmp${num}
    else
        echo "Error: »${minmax}« does not exist or has wrong format." >&2
        exit $EXIT_ERROR
    fi
done || exit $EXIT_ERROR

# average
echo "Calculate histogram for ${name}, col ${column}, average"
${scripts}/av_second_column.py ${outfile}.tmp[0-9]*[0-9] > ${outfile} &&
    find -type f -regex "[./]*${outfile}.tmp[0-9]+" -delete

exit $EXIT_SUCCESS
