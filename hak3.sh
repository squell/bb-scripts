#! /bin/bash

# partition ALL SUBDIRECTORIES in equal parts into the folders given as arguments

shopt -s nullglob

if [ -z "$1" ]; then
    echo "usage: hak3.sh <dir1> <dir2> ... <dirN>" >&2
    exit 1
fi

N=$#

i=$RANDOM
until [ -z "$1" ]; do
    # temporarily hide the folders we are sorting into
    test -d "$1" && mv "$1" ".$1"
    mkdir -p ".$1"
    dir[$((i++%N))]="$1"
    shift
done

i=0
shuf -ze */ | while read -d $'\0' stud; do
    mv "$stud" ."${dir[$((i++%N))]}"
done

for dir in "${dir[@]}"; do
    mv ".$dir" "$dir"
done
