#! /bin/bash

# converteert een blackboard zip naar een directory structuur (bb 9.1)

umask 077

if [ -z "$1" ]; then
	echo Usage: bbfix bestand.zip
	exit 1
fi

if [ ! -e "$1" ]; then
	echo Could not find $1
	exit 2
fi

TEMP=EXTRACT
FILTER=" ()-"

unzip -q -o -d "$TEMP" "$1"

for bbfile in "$TEMP"/*; do
	bbfile="${bbfile#*/}"
	basename="${bbfile#*attempt_20[0-9-]*_}"
	studnr="${bbfile#*_s}"
	studnr="${studnr%%[^0-9]*}"
	dir="s${studnr}"
	if [ -z "$studnr" ]; then
		dir="attic"
	elif [ "$basename" == "$bbfile" ]; then
		basename="${dir}.txt"
	fi
	#echo DEBUG $bbfile -- $studnr -- $basename
	mkdir -p "$dir"
	mv "$TEMP/${bbfile}" "${dir}/${basename}"
done

rmdir "$TEMP"

