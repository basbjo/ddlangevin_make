#!/bin/bash
#Description

SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
NARGS=$#
NARGS_NEEDED=1

usage() {
    echo "
$SCRIPTNAME: Description

Usage: $0 [-o opt|-n] argument
Options:
    -h          display these options
    -o str      option with string argument
    -n          option without argument
Arguments:
    - argument:     description

Detailed description
" >&2
    [ $NARGS -eq 1 ] && exit $1 || exit $EXIT_FAILURE
}

# get command line options
while getopts ':o:nh' OPTION
do
    case $OPTION in
        h)
            usage $EXIT_SUCCESS
            ;;
        o)
            option="$OPTARG"
            ;;
        n)  otheroption=
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

# missing arguments
if [ $NARGS -ne $NARGS_NEEDED ]
then
    usage $EXIT_ERROR
fi

# get command line arguments
scripts=$(dirname $0)
arg=$1

# get things done

exit $EXIT_SUCCESS
