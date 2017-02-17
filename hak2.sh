#! /bin/bash

# verdeel alle s* directories in gelijke delen over de argumenten
# als de argumenten al bestaan en mapjes bevatten, kopieert het de inhoud

if [ -z "$1" ]; then
    echo "usage: hak2.sh <dir1> <dir2> ... <dirN>"
    exit 1
fi

N=$#

i=$RANDOM
until [ -z "$1" ]; do
   mkdir -p "$1"
   # move contents of directories already present
   for prestud in "$1"/[usefz][0-9]*; do
       stud="${prestud##*/}"
       if [ -d "$prestud" ] && [ -d "$stud" ]; then
	   mv -u "$stud"/* "$prestud"
	   rm -rd "$stud"
       fi
   done
   dir[$((i++%N))]="$1"
   shift
done

# de 'grep' is hier slechts een extra safety; zou eigenlijk niet nodig moeten zijn.
# als je die aanpast wil je ook in groepjes.sh waarschijnlijk even rondneuzen.
i=0
for stud in `ls -d [usefz][0-9]* 2> /dev/null | grep "[usefz][0-9]\{6,7\}" | sort -R`; do
   mv "$stud" "${dir[$((i++%N))]}"
done
