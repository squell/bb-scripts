#! /bin/bash

# verdeel alle s* directories in gelijke delen over de argumenten

if [ -z "$1" ]; then
    echo "usage: hak2.sh <dir1> <dir2> ... <dirN>"
    exit 1
fi

declare -A dir
N=$#

i=$RANDOM
until [ -z "$1" ]; do
   mkdir -p "$1"
   dir[$((i++%N))]="$1"
   shift
done

# de 'grep' is hier slechts een extra safety; zou eigenlijk niet nodig moeten zijn.
# als je die aanpast wil je ook in groepjes.sh waarschijnlijk even rondneuzen.
i=0
for stud in `ls -d [sez][0-9]* | grep "[sez][0-9]\{6,7\}" | sort -R`; do
   mv "$stud" "${dir[$((i++%N))]}"
done
