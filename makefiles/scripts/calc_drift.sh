#!/bin/bash
#Calculate drift

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=6
BINS=50

usage() {
    echo "
$SCRIPTNAME: Calculates drift fields of »file« for columns »col1« and »col2«

Usage: $0 file col1 col2 minmax driftdir if_future [unit]
Arguments:
    - file:         data file
    - col1:         first column
    - col2:         second column
    - minmax:       reference file with minima and maxima,
                    must contain two lines with minima and maxima
    - driftdir:     subdirectory for results
    - if_future:    1 in case of several trajectories, 0 else
    - unit:         unit to extract time step from filename

Results are written to »driftdir«. Minimum ranges for binning are read from
»minmax«. If »unit« is given, the correct time step is extracted from
»file« name with format »name_<step><unit>«, otherwise it is set to one.
If »iffuture« is one, a zero in the last column denotes trajectory ends.
" >&2
    [ $NARGS -eq 1 ] && exit $1 || exit $EXIT_FAILURE
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
col1=${2#0}
col2=${3#0}
minmax=$4
driftdir=$5
iffuture=$6
unit=$7
# outfilenames
outfile1=${driftdir}/${file}-V${2}-V${3}.1ddrifthist
outfile2=${driftdir}/${file}-V${2}-V${3}.2ddrifthist

# future column is necessary
if [ ${iffuture} -eq 0 ]
then
    echo "Error in $0: »iffuture=0« not implemented!" >/dev/stderr
    exit 1
fi

# minmax file is necessary
if [ -z "${minmax}" ] || [ ! -f ${minmax} ]
then
    echo "Error: minmax file is required (»${minmax}« not found)!" >/dev/stderr
    exit 1
fi

# determine time step from filename if unit is known
if [ $# -eq 7 ] && [ -n ${unit} ]
then
    step=$(echo ${file}|egrep -o -- "_[0-9.]+${unit}"|grep -o '[0-9.]*[0-9]')
    if [ -z "${step}" ]
    then
        echo "Error: time step with unit »${unit}« cannot be extracted from filename »${file}«." >&2
        exit $EXIT_ERROR
    fi
else
    step=1
fi

# driftfield calculation
calcdrift() {
    cat /dev/stdin |
    awk -v step=${step} -v col1=$col1 -v col2=$col2 '
{
    if(NR>1 && follower!=0) {
        print $col1,$col2,($col1-prev[0])/step,($col2-prev[1])/step
    }
    prev[0]=$col1
    prev[1]=$col2
    follower=$NF
}'
}

# driftfield binning (2d) and integration of one dimension for 1d result
bindrift() {
    cat $minmax /dev/stdin |
    awk -v bins=$BINS -v out1d=${outfile1} -v out2d=${outfile2} '
{
    # read minima and maxima from minmax file to set ranges
    if(NR==1){
        for(i=0;i<2;i++){
            min[i]=$(i+1)
        }
    }
    if(NR==2){
        for(i=0;i<2;i++){
            max[i]=$(i+1)
            range[i]=max[i]-min[i]
        }
    }

    # binning
    if(NR>=3){
        i=int(bins*($1-min[0])/range[0])
        j=int(bins*($2-min[1])/range[1])
        hist1[i,j]+=$3
        hist2[i,j]+=$4
        sum[i,j]+=1
    }
}
END {
    # normalization
    for(i=0;i<bins;i++){
        for(j=0;j<bins;j++){
            if(sum[i,j]>0){
                hist1[i,j]=hist1[i,j]/sum[i,j]
                hist2[i,j]=hist2[i,j]/sum[i,j]
            }
        }
    }

    # integrate over x-axis
    for(j=0;j<bins;j++){
        summe=0
        for(i=0;i<bins;i++){
            if(sum[i,j]>0){
                histxofy[j]+=hist1[i,j]
                histyofy[j]+=hist2[i,j]
                summe++
            }
        }
        if(summe>0){
            histxofy[j]=histxofy[j]/summe
            histyofy[j]=histyofy[j]/summe
        }
    }

    # integrate over y-axis
    for(i=0;i<bins;i++){
        summe=0
        for(j=0;j<bins;j++){
            if(sum[i,j]>0){
                histxofx[i]+=hist1[i,j]
                histyofx[i]+=hist2[i,j]
                summe++
            }
        }
        if(summe>0){
            histxofx[i]=histxofx[i]/summe
            histyofx[i]=histyofx[i]/summe
        }
    }

    # print 1d results
    printf("#x hx(x) hy(x) y hx(y) hy(y)\n") >out1d
    for(i=0;i<bins;i++){
        printf("%.3f %.3f %.3f %.3f %.3f %.3f\n",\
            (min[0]+i/bins*range[0]),histxofx[i],histyofx[i],\
            (min[1]+i/bins*range[1]),histxofy[i],histyofy[i]) >out1d
    }

    # print 2d results
    printf("#x y v_x v_y\n") >out2d
    for(i=0;i<bins;i++){
        for(j=0;j<bins;j++){
            if((hist1[i,j]!=0) || (hist2[i,j]!=0)) {
                print (min[0]+i/bins*range[0]),(min[1]+j/bins*range[1]),\
                    hist1[i,j],hist2[i,j] >out2d
            }
        }
    }
}
'
}

# call functions and write to files
cat ${file} | calcdrift | bindrift

exit $EXIT_SUCCESS
