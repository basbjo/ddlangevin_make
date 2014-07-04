#!/bin/bash
#Wrapper for plot_corrtimes.gp
#Uses plot_corrtimes.gp

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=2

function usage {
    echo -e "
$SCRIPTNAME: Wrapper for plot_corrtimes.gp

Usage: $0 file xrange [unit]
Arguments:
    - file:         data file
    - xrange:       xrange in format \"[xmin]:[xmax]\"
    - unit:         time unit to be shown in x label
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
file=$1
xrange=$2
unit=$3
ymin=${xrange%%:*}
ymax=${xrange##*:}

lag=`echo $file | egrep -o 'lag[0-9]+' | grep -o '[0-9]*'`

options="FILE=\\\"${file}\\\";LAG=${lag}"

if [ "${ymin}" != "" ]
then
    options="${options}; ymin=${ymin}"
fi

if [ "${ymax}" != "" ]
then
    options="${options}; ymax=${ymax}"
fi

if [ $# -eq 3 ]
then
    scale=$(echo ${file}|egrep -o -- "_[0-9.]+${unit}"|grep -o '[0-9.]*[0-9]')
    options="${options}; SCALE=${scale}; UNIT=\\\"${unit}\\\""
fi

echo "gnuplot -e \"${options}\" ${scripts}/plot_corrtimes.gp"
eval "gnuplot -e \"${options}\" ${scripts}/plot_corrtimes.gp"

exit $EXIT_SUCCESS
