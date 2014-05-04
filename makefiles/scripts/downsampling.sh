#!/bin/bash
#Down sampling of several datafile-## with follower column

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=4

function usage {
    echo -e "
$SCRIPTNAME: Downsampling and concatenation of several trajectories

Usage: $0 splitdir name step iffuture
Arguments:
    - splitdir:     directory with split data name-01, name-02, ...
    - name:         filename root
    - step:         down sampling step
    - iffuture:     1 in case of several trajectories, 0 else

Trajectories splitdir/name-## are down sampled with starting points
# = 1,2,...,step, concatenated and written to name_ds<step>-#.
Then these files are concatenated and written to name_ds<step>.
If iffuture is 1, the last column should be 0 at the end of files and 1
else, so a 1 at the end of down sampled trajectories is changed to 0.
If iffuture is 0, only name is read instead of splitdir/name-##.
" >&2
    [[ $NARGS -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

# get command line options

# missing arguments
if [ $NARGS -ne $NARGS_NEEDED ]
then
    usage $EXIT_ERROR
fi

# get command line arguments
dir=$1
name=$2
n=$3
iffuture=$4

# if last column denotes end of trajectories
if [ ${iffuture} -eq 1 ]
then
    # denote end of trajectories by a 0
    sedscr='$s/ 1 *$/ 0/'
else
    # do nothing
    sedopt='-n'
    sedscr='p'
fi

# down sampling
find -type f -regex "./${name}_ds${n}\(-[0-9]*\)?" -delete
start=1 # take first value of n values first
while [ ${start} -le ${n} ]
do
    if [ ${iffuture} -eq 1 ]
    then
        find -L ${dir} -type f -regex ${dir}/${name}-[0-9]\* | sort
    else
        echo ${name}
    fi \
        | while read file
          do
              awk -vn=${n} -vstart=${start} '
              !/^#/ {
                  if(! ((NR-start) % n)) {
                      print $0
                  }
              }' "$file" | sed ${sedopt} "${sedscr}" \
                  >> `printf "%s_ds%d-%02d" ${name} ${n} ${start}`
          done
    start=`expr ${start} + 1`
done
cat ${name}_ds${n}-[0-9]*[0-9] > ${name}_ds${n}

exit $EXIT_SUCCESS
