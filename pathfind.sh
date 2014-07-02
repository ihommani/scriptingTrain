#! /bin/sh
#
# Search for one or more ordinary files or file patterns on a search path defined by a specified environement variable
#
# The output on standaed output is normally either the full path to the first instance of each file found on the search path
# , or "filename: not found" on standard error.
#
# The exit code is 0 if all files are found, and otherwise a nonzero value equal to the number of files not found
#
# Usage: 
# pathfind [--all] [--?] [--help] [--version] envvar pattern(s)
# with the --all pption, every directory in the path is searched, instad of sropping with the first one found



#########################
######## SECURITY #######
#########################

IFS='
    '

OLDPATH="$PATH"

PATH=/bin:/usr/bin
export PATH


error()
{
    echo "$@" 1>&2
    usage_and_exit 1
}

usage()
{
    # We never harcode the program's name. Get reid off duplication and ease program renaming in colision case
    echo "Usage: $PROGRAM [--all] [--?] [--help] [--version] envvar pattern(s)"
}

usage_and_exit()
{
    usage
    exit $1
}

version()
{
    echo "$PROGRAM version $VERSION"
}

warning()
{
    echo "$@" 1>&2
    EXITCODE=$(($EXITCODE + 1))
}



all=yes # I think that string in this case make things clearer
envvar=
EXITCODE=0
PROGRAM=$(basename $0)
VERSION=1.0


##########################
# ARGUTMENTS PARSING ####
##########################

while [ $# -gt 0 ]
do
    case $1 in
    --all | --al | --a | -all | -al | -a )
        all=yes
        ;;
    --help | --hel | --he | --h | -help | -hel | -he | -h | '--?' |  '-?' )
        usage_and_exit 0
        ;;
    --version | --versio | --versi | --vers | --ver | --ve | --v | -version | -versio | -versi | -vers | -v )
        version
        ;;
    -*)
        error "Unreconized option: $1"
        ;;
    *)
        break # We break the while loop, since there is no more option to parse
        ;;
    esac
    shift # Allow to downgrade the option number. $n becomes $n-1 and $1 is thrown away
done

# From now the first argument is the envvar path
envvar="$1" 
test $# -gt 0 && shift # We throw away $1 and replace it with $2 i.e the search pattern

# x[] is a small trick in case of envvar begins with an hyphen
test "x$envvar" = "xPATH" && envvar=OLDPATH # In case the envvar is actually the user PATH we just override at the beginning

dirpath=$(eval echo '${'"$envvar"'}' 2>/dev/null | tr : ' ') # tricky part

if [ -z "$envvar" ]
then
    error Environment variable missing or empty
elif [ "x$dirpath" = "x$envvar" ]
then
    error "Broken sh on this platform: cannot expand $envvar"
elif [ -z "$dirpath" ]
then
    error Empty directory search path
elif [ $# -eq 0 ]
then # Nothing to do ?
    exit 0
fi


for pattern in "$@"
do
    result=
    for dir in $dirpath
    do
        for file in $dir/$pattern
        do
            if [ -f "$file" ]
            then
                result="$file"
                echo $result
                test "$all" = "no" && break 2
            fi
        done
    done
    test -z "$result" && warning "$pattern: not found"
done

# In some shell exit code cannot exceed 125
test $EXITCODE -gt 125 && EXITCODE=125

exit $EXITCODE

