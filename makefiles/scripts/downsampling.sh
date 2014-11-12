#!/bin/bash
#Down sampling of several datafile-## with follower column

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=5

usage() {
    echo "
$SCRIPTNAME: Downsampling and concatenation of several trajectories

Usage: $0 splitdir splitname name step iffuture
Arguments:
    - splitdir:     directory with split data name-01, name-02, ...
    - splitname:    splitfilename root
    - name:         outfilename root
    - step:         down sampling step
    - iffuture:     1 in case of several trajectories, 0 else

Trajectories splitdir/splitname-## are down sampled with starting points
# = 1,2,...,step, concatenated and written to name_ds<step>-#.
Then these files are concatenated and written to name_ds<step>.
If iffuture is 1, the last column should be 0 at the end of files and 1
else, so a 1 at the end of down sampled trajectories is changed to 0.
If iffuture is 0, only name is read instead of splitdir/name-##.
" >&2
    [ $NARGS -eq 1 ] && exit $1 || exit $EXIT_FAILURE
}

# get command line options
if [ "$1" = "-h" ]
then
    usage $EXIT_SUCCESS
fi

# missing arguments
if [ $NARGS -ne $NARGS_NEEDED ]
then
    usage $EXIT_ERROR
fi

# get command line arguments
dir=$1
splitname=$2
name=$3
n=$4
iffuture=$5

# down sampling
find -type f -regex "./${name}_ds${n}\(-[0-9]*\)?" -delete
if [ ${iffuture} -eq 1 ]
then
    find -L ${dir} -type f -regex ${dir}/${splitname}-[0-9]\* | sort
else
    echo ${name}
fi \
    | while read file
        do
            # down sampling
            fileroot=`printf "%s_ds%d" ${name} ${n}`
            awk -vn=${n} -vfileroot=${fileroot} -viffuture=${iffuture} '
            !/^#/ {
                counter++
                traj = ((counter-1) % n) + 1
                if(last[traj] != "") {
                    print last[traj] >>sprintf("%s-%02d", fileroot, traj)
                }
                last[traj] = $0

                if(! (counter % 10000)) {
                    printf("\r%s: lines processed: %d", FILENAME, counter) > "/dev/stderr"
                }
            }
            END {
                if(counter>=10000) {
                    printf("\n") > "/dev/stderr"
                }
                for(traj=1;traj<=n;traj++) {
                    if(last[traj] != "") {
                        if(iffuture == 1) {
                            sub(" 1$"," 0",last[traj])
                        }
                        print last[traj] >>sprintf("%s-%02d", fileroot, traj)
                    }
                }
            }' "${file}"
        done
echo "cat ${name}_ds${n}-[0-9]*[0-9] > ${name}_ds${n}"
eval "cat ${name}_ds${n}-[0-9]*[0-9] > ${name}_ds${n}"

exit $EXIT_SUCCESS
