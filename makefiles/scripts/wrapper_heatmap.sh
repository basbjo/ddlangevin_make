#!/bin/bash
#Plot a 2D histograms with heatmap and z-range from reference file

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=3

TITLESTART="2D FEL for"

function usage {
    echo -e "
$SCRIPTNAME: Plot a 2D histograms with heatmap

Usage: $0 heatmap infile reffile [options]
Arguments:
    - heatmap:      path to heatmap script
    - infile:       input filename such as root.detail-V01-V02.hist
    - reffile:      reference data file to set color bar range
    - options:      options that are passed to the heatmap script

The plot title is »${TITLESTART} root[.detail]-V##-V##«.
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
heatmap=$1
infile=$2
reffile=$3
unit=$4
shift ${NARGS_NEEDED}
options=$*
suffix=$(echo ${infile}|egrep -o -- '-V[0-9]+-V[0-9]+(\..*)?')

# plot title
name=$(basename ${infile})
title="-t \"${TITLESTART} ${name%.*}\""

# reference file to set z-range
if [[ "${reffile}" != "" ]]
then
    zref="--z-ref ${reffile}"
fi

# plotting
echo ${heatmap} ${infile} ${zref} ${title} ${options}
eval ${heatmap} ${infile} ${zref} ${title} ${options}

exit $EXIT_SUCCESS
