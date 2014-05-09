#!/bin/bash
#Print out column wise minimum and maximum values
#Lines that begin with COMMENT_CHARS are ignored

#Author: Bjoern Bastian <bjoern.bastian@physik.uni-freiburg.de>

COMMENT_CHARS="#@"
OFMT="%.6g" # default output format for numbers
OFS="\t"    # default field separator
SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#

function usage {
    echo -e "
$SCRIPTNAME: Determines column wise minima and maxima

Usage: $SCRIPTNAME [option]... [file]...
Options:
If no file is given stdin is read. Just - also means stdin.
Lines starting with regular expression \"^[$COMMENT_CHARS]\" are ignored.
        -h      show these options
        -d str  output delimiter [default \"$(
                           sed -n l <<< $OFS  | head -c-2)\"]
        -f str  output format for numbers [default \"$OFMT\"]

Output format:
        min1 min2 ...
        max1 max2 ...
" >&2
    [[ $NARGS -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

# get command line options
while getopts ':d:f:h' OPTION
do
    case $OPTION in
        h)
            usage $EXIT_SUCCESS
            ;;
        d)
            OFS="$OPTARG"
            ;;
        f)
            OFMT="$OPTARG"
            ;;
        \?)
            echo "Unknown option \"-$OPTARG\"." >&2
            usage $EXIT_ERROR
            ;;
        :)
            echo "Option \"-$OPTARG\" needs an argument." >&2
            usage $EXIT_ERROR
            ;;
    esac
done
# skip unused arguments
shift $(( OPTIND - 1 ))
NARGS=$#

# read data
if [ $NARGS -gt 0 ]
then
    # read files
    cat "$@"
else
    # read from stdin
    cat /dev/stdin
fi |
grep -v "^[$COMMENT_CHARS]" |
awk -v OFMT="$OFMT" -v OFS="$OFS" -v isfirstline=1 -v script="$SCRIPTNAME" '
{

    # get first values
    if (isfirstline)
    {
        ncols = NF
        for(i=1; i<=ncols; i++)
        {
            min[i] = $i
            max[i] = $i
        }
        isfirstline = 0
    }

    # update minima and maxima
    for(i=1; i<=ncols; i++)
    {
        if($i < min[i])
        {
            min[i] = $i
        }
        else if($i > max[i])
        {
            max[i] = $i
        }
    }
    if(! (NR % 10000))
    {
        printf("\r%s: lines processed: %d", script, NR) > "/dev/stderr"
    }
}
END {
    if(NR>=10000) {
        printf("\n") > "/dev/stderr"
    }

    # print minima
    for(i=1; i<=ncols; i++) {
        printf(OFS OFMT, min[i])
    }
    printf("\n")

    # print maxima
    for(i=1; i<=ncols; i++) {
        printf(OFS OFMT, max[i])
    }
    printf("\n")
}
'

exit $EXIT_SUCCESS
