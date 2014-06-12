#! /usr/bin/bash

set -u
set -e

cat << EOF
##################################
Welcome to the move files utility.
##################################
EOF

function usage {
    echo -n '
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

options="e:d:h"
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
        \?) usage;;
    esac
done


# Basic verification
if [ -z "$dir_flag" ]
    then
        echo "Target directory is mandatory. Exiting"
        exit 1
fi

if [ -z "$ext_flag" ]
    then
        echo "extension is mandatory. Exiting"
        exit 1
fi

if  [ ! -d "$destination_directory" ]
    then
        echo "$destination_directory is not a valid path. Exiting."
        exit 1
fi

files_to_move=$(ls *.$extension_file)

echo "Moving *.$extension_file files to the directory $destination_directory."
for file in $files_to_move;
    do
        mv $file $destination_directory
    done;

