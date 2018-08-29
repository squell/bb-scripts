#! /bin/bash

# partition AL SUBDIRECTORIES in equal parts into the folders given as arguments
# if such a directory structure already exists, the existing structure will be
# respected, and files moved accordingly (this allows non-random assignment of work to ta's)

if [ -z "$1" ]; then
    echo "usage: hak3.sh <dir1> <dir2> ... <dirN>"
    exit 1
fi

N=$#

i=$RANDOM
until [ -z "$1" ]; do
    mkdir -p ".$1"
    # move contents of directories already present
#   for prestud in "$1"/*/; do
#       stud="${prestud##*/}"
#       if [ -d "$prestud" ] && [ -d "$stud" ]; then
#	   mv -u "$stud"/* "$prestud"
#	   rm -rd "$stud"
#       fi
#   done
    dir[$((i++%N))]="$1"
    shift
done

# the use of 'grep' is an additional safety against mis-use of this script;
# in case you (need to) edit it here, you should also nose around in groepjes.sh
i=0
for stud in */; do
    mv "$stud" ."${dir[$((i++%N))]}"
done

for dir in "${dir[@]}"; do
    mv ".$dir" "$dir"
done
