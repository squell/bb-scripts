#! /bin/bash

# partition ALL SUBDIRECTORIES in equal parts into the folders given as arguments
shopt -s nullglob

numFolders=$(find * -maxdepth 0 -type d | wc -l)

if [ -z "$1" ]; then
    echo "usage: hak3.sh <dir1> <dir2> ... <dirN>" >&2
    exit 1
fi

N=$(($#/2))

i=$RANDOM
typeset -A distribution
until [ -z "$1" ]; do
    # temporarily hide the folders we are sorting into
    test -d "$1" && mv "$1" ".$1"
    mkdir -p ".$1"
    dir[$((i%N))]="$1"
    echo "dir: $1"
    shift
    echo "val: $1"
    distribution[$((i++%N))]=$(echo "$1*$numFolders" | bc | mawk '{print int($1+0.5)}')
    shift
done

part(){
    j=$1

    if [ "${distribution[$(((i+j)%N))]}" -gt "0" ]; then
        mv "$stud" ."${dir[$(((i+j)%N))]}"
        echo $((j+1))
        return
    fi

    if [ "$j" -ge "$N" ]; then
        echo "FUCK"
    fi

    echo $(part $((j+1)))
}

i=0
shuf -ze */ | while read -d $'\0' stud; do
    j=$(part 0)
    i=$((i+j))
    distribution[$(((i-1)%N))]=$((${distribution[$(((i-1)%N))]}-1))
done

for dir in "${dir[@]}"; do
    mv ".$dir" "$dir"
done
