#! /usr/bin/bash

set -u
set -e

cat << EOF
##################################
Welcome to the move files utility.
##################################
EOF

function usage {
    printf  '
DESCRIPTION
    This little utility allow you to move all files
    with a specific extension to a specific directory.
    Both extension (-e) and target directory (-d) are
    mandatory.

    -e: Specify extension
    -d: Specify directory. Must be a valid path
    -h: Display this manual

EXAMPLE
    move_file -e sh -d /va/li/d/pa/th
    '
}

dir_flag=
ext_flag=

options=":e:d:h"
#Process the arguments
while getopts $options opt
do
    case "$opt" in
        e)  ext_flag=1 
            extension_file=$OPTARG;;
        d)  dir_flag=1 
            destination_directory=$OPTARG;;
        h)  usage
            exit;;
        \?) printf "\n\t%s: invalid option -%s\n" $0 $OPTARG >&2
            usage >&2
            exit 1
            ;;
    esac
done


# Basic verification
dir_flag=${dir_flag:? "Target directory is mandatory. Exiting"}
ext_flag=${ext_flag:? "extension is mandatory. Exiting."}

if  [ ! -d "$destination_directory" ]
    then
        printf "%s is not a valid path. Exiting." $destination_directory
        exit 1
fi

files_to_move=$(ls *.$extension_file)

printf "Moving *.%s files to the directory %s." $extension_file $destination_directory
for file in $files_to_move;
    do
        printf "\nMoving  %s\t" $file
        mv $file $destination_directory
    done;

