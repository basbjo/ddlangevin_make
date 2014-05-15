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

Usage: $0 heatmap refdir infile [options]
Arguments:
    - heatmap:      path to heatmap script
    - refdir:       directory where to search for a reference file
    - infile:       input filename such as root.detail-V01-V02.hist
    - options:      options that are passed to the heatmap script

For a filename with format »[dir/]root[.detail]-V##-V##[.suffix]«, a reference
file »refdir/root*-V##-V##[.suffix]« is used to set the z-range, if it exists.
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
heatmap=$1
refdir=$2
infile=$3
shift ${NARGS_NEEDED}
options=$*
suffix=$(echo ${infile}|egrep -o -- '-V[0-9]+-V[0-9]+(\..*)?')
base=${infile/${suffix}/}
reffiles=$(echo ${refdir}/${base%%.*}*${suffix})
reffile=${reffiles%% *} # consider one file only

# plot title
name=$(basename ${infile})
title="-t \"${TITLESTART} ${name%.*}\""

# reference file to set z-range
if [ -f ${reffile} ]
then
    zref="--z-ref ${reffile}"
fi

# plotting
echo ${heatmap} ${infile} ${zref} ${title} ${options}
eval ${heatmap} ${infile} ${zref} ${title} ${options}

exit $EXIT_SUCCESS
