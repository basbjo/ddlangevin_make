#!/bin/bash
#Determine number of columns and rows
#Lines that begin with COMMENT_CHARS are ignored

#Author: Bjoern Bastian <bjoern.bastian@physik.uni-freiburg.de>

COMMENT_CHARS="#@"
OFS="\t"    # default field separator
PRINT_ALL=true  # print filenames
PRINT_COLS=true # print number of columns
PRINT_ROWS=true # print number of rows
SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#

usage() {
    echo "
$SCRIPTNAME: Determines number of columns and rows

Usage: $SCRIPTNAME [option]... file...
Options:
Lines starting with regular expression \"^[$COMMENT_CHARS]\" are ignored.
        -h      show these options
        -d str  output delimiter [default \"$OFS\"]
        -c      only print number of columns ncols
        -r      only print number of rows nrows

Output format:
        file1 ncols nrows
        ...
" >&2
    [ $NARGS -eq 1 ] && exit $1 || exit $EXIT_FAILURE
}

# get command line options
while getopts ':d:crh' OPTION
do
    case $OPTION in
        h)
            usage $EXIT_SUCCESS
            ;;
        d)
            OFS="$OPTARG"
            ;;
        c)  PRINT_ROWS=
            PRINT_ALL=
            ;;
        r)  PRINT_COLS=
            PRINT_ALL=
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

# missing file names
if [ $NARGS -eq 0 ]
then
    usage $EXIT_ERROR
fi

for i in "$@"
do
    if [ -f "$i" ]
    then
        test $PRINT_ALL && echo -en "$i" || true
        test $PRINT_ALL && echo -en "$OFS" || true
        test $PRINT_COLS && echo -en \
            "$(egrep -v "^([$COMMENT_CHARS]| *$)" "$i" | head -1 | wc -w)" \
            || true
        test $PRINT_ALL  && echo -en "$OFS" || true
        test $PRINT_ROWS && echo -en \
            "$(egrep -v "^([$COMMENT_CHARS]| *$)" "$i" | wc -l)" \
            || true
        echo -en "\n"
    fi
done

exit $EXIT_SUCCESS
