#!/bin/bash
#Search reference file by omitting suffixes/changing time step

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=2

function usage {
    echo -e "
$SCRIPTNAME: Search reference file by omitting suffixes/changing time step

Usage: $0 refdir filename [unit]
Arguments:
    - refdir:     directory to search for reference file
    - filename:   file for which to search reference file
                  (the filename may contain directory parts)

For a filename with format »[dir/]root[.detail]-V##[-V##][.suffix]«, a reference
filename »refdir/[dir/]root*-V##[-V##][.suffix]« is printed, if the file exists.
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
refdir=$1
filename=$2
unit=$3

# extract suffix from filename
suffix=$(echo ${filename}|egrep -o -- '-V[0-9]+-V[0-9]+(\..*)?')
if [[ "${suffix}" == "" ]]
then
    suffix=$(echo ${filename}|egrep -o -- '-V[0-9]+(\..*)?')
fi

# omit suffixes until a reference file is found in refdir
pattern=${filename/${suffix}/}
startpattern=${pattern}
timewildsearch=
while [[ "${reffile}" == "" ]] && [[ "${pattern}" != "" ]]
do
    reffile=$(find -L ${refdir} -type f -regex ${refdir}/${pattern}${suffix})
    if [[ "${pattern%.*}" == "${pattern}" ]]
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

# print reffile if not identical to filename or not found
if [[ "${reffile}" != "" ]] && [[ "${filename}" != "" ]]
then
    path=$(readlink -f ${filename})
    refpath=$(readlink -f ${reffile})
fi
if [[ "${reffile}" != "" ]] && [[ "${path}" != "${refpath}" ]]
then
    echo ${reffile}
fi

exit $EXIT_SUCCESS
