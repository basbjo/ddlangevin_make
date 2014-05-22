#!/bin/bash
#Plot a 2D histograms with heatmap and z-range from reference file

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=4

TITLESTART="2D FEL for"

function usage {
    echo -e "
$SCRIPTNAME: Plot a 2D histograms with heatmap

Usage: $0 heatmap infile refdir unit [options]
Arguments:
    - heatmap:      path to heatmap script
    - infile:       input filename such as root.detail-V01-V02.hist
    - refdir:       directory where to search for a reference file
    - unit:         unit to find reference with different sampling time
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
infile=$2
refdir=$3
unit=$4
shift ${NARGS_NEEDED}
options=$*
suffix=$(echo ${infile}|egrep -o -- '-V[0-9]+-V[0-9]+(\..*)?')
# omit suffixes until a reference file is found in refdir
pattern=${infile/${suffix}/}
startpattern=${pattern}
timewildsearch=
while [[ "${reffile}" == "" ]] && [[ "${pattern}" != "" ]]
do
    reffile=$(find -L ${refdir} -type f -regex ${refdir}/${pattern}${suffix})
    if [[ ${pattern%.*} == ${pattern} ]]
    then
        if [[ "${unit}" != "" ]]
        then
            # search files with different sampling time
            time=$(echo ${startpattern}|egrep -o -- "_[0-9]+${unit}")
            pattern=${startpattern/${time}/_[0-9]+${unit}}
            # stop searching
            test ${timewildsearch} && break
            timewildsearch=true
        else
            # stop searching
            break
        fi
    fi
    pattern=${pattern%.*}
done

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
