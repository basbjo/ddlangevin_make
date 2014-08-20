#!/bin/bash
#Estimate corrtimes and append range for subsequent data creation to *.fit
#Uses fit_corrtime.gp

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=7

usage() {
    echo "
$SCRIPTNAME: Estimate corrtimes and append range for subsequent data creation to .fit file

Usage: $0 file column fitdir if_future estimlength rangefactor program [options]
Arguments:
    - file:         data file
    - column:       column number
    - fitdir:       directory for results from corrtime estimation
    - if_future:    1 in case of several trajectories, 0 else
    - estimlength:  correlation length for first estimate
    - rangefactor:  final data will be calculated on rangefactor*corrtime
    - program:      typically TISEAN corr with option -V0
    - options:      options that are passed to program
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
file=$1
column=$((10#$2)) # decimal representation forced, leading zeros removed
fitdir=$3
future=$4
estimlength=$5
rangefactor=$6
program=$7
shift ${NARGS_NEEDED}
options=$*
minrange=100
fitlog=${fitdir}/$(printf "%s-V%02d.fit" ${file} ${column})
corfile=${fitlog}.cor

echo "Estimate correlation time for ${file} (column ${column})..."

# remove old fit results
rm -f ${fitlog}*

# calculate autocorrelation
if [ ${future} == 1 ]
then
    # only use the first continuous trajectory
    sed '/^[^#].* 0$/q' ${file} # quits if last column is zero
else
    # use whole file
    cat ${file}
fi | ${program} ${options} -c${column} -D ${estimlength} \
   | awk '!/^#/ {if($2<exp(-1))exit;print $0}' > ${corfile}
   # stop calculation when correlation falls below exp(-1)

# correlation time estimation by linear fit to log data
tcorr=`gnuplot -e "FILE=\"${corfile}\"; FITLOG=\"${fitlog}\"" \
    -e "PNG=\"${fitlog}.png\"" ${scripts}/fit_corrtime.gp 2>&1 | tail -n1`

# range for final autocorrelation data (not created here)
if [ "${tcorr}" != "" ]
then
    # successful fit
    range=$((${tcorr} * ${rangefactor}))
    if [ $range -lt $minrange ]
    then
        # minimum range
        range=$minrange
    fi
else
    # unsuccessful fit (e.g. too few points)
    range=$minrange
fi
echo -e "\nrange for plots:\n\n${range}" >> ${fitlog}

exit $EXIT_SUCCESS
