#!/bin/bash
#Calculate averaged 1D histogram file-V#.hist from file-##
#Uses av_second_cols.awk

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=6

DELIMITER=" "

function usage {
    echo -e "
$SCRIPTNAME: Calculate averaged 1D histogram for one column

Usage: $0 name column minmax splitdir outdir program [options]
Arguments:
    - name:         filename root
    - column:       column number
    - minmax:       reference file with minima and maxima or \"\",
                    must contain two lines with minima and maxima
    - splitdir:     directory with split data name-01, name-02, ...
    - outdir:       directory for temporary files and result
    - program:      typically TISEAN histogram with option -V0
    - options:      options that are passed to program

The minimum range is set by concatenating minmax to input.
The average of the histograms of »splitdir/name-##« where
## = 01,02,... is written to »outdir/name-V<col>.hist«.
" >&2
    [[ $NARGS -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

# get command line options

# missing arguments
if [ $NARGS -lt $NARGS_NEEDED ]
then
    usage $EXIT_ERROR
fi

# get command line arguments
scripts=$(dirname $0)
name=$1
column=$2
minmax=$3
splitdir=$4
outdir=$5
program=$6
shift ${NARGS_NEEDED}
options=$*
outfile=${outdir}/${name}-V${column}.hist

# calculate histograms for each trajectory
find -L ${splitdir} -regex "[./]*${splitdir}/${name}-[0-9]+" | while read traj
do
    num=${traj##*-}
    echo "Calculate histogram for ${name}, col ${column}, traj ${num}"
    if [[ "${minmax}" == "" ]]
    then
        ${program} -c${column} ${options} ${traj} -o ${outfile}.tmp${num}
    elif [ -f ${minmax} ] && [ $(wc -l ${minmax}|awk '{print $1}') -eq 2 ]
    then
        cat ${minmax} ${traj}\
            | ${program} -c${column} ${options} -o ${outfile}.tmp${num}
    else
        echo "Error: »${minmax}« does not exist or has wrong format." >&2
        exit $EXIT_ERROR
    fi
done || exit $EXIT_ERROR

# paste and average
echo "Calculate histogram for ${name}, col ${column}, average"
paste -d"${DELIMITER}" ${outfile}.tmp[0-9]*[0-9] \
    | ${scripts}/av_second_cols.awk \
    > ${outfile} &&
    find -type f -regex "[./]*${outfile}.tmp[0-9]+" -delete

exit $EXIT_SUCCESS
