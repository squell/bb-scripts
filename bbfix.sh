#! /bin/bash

# converteert een blackboard zip naar een directory structuur (bb 7.3)

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

unzip -q -d "$TEMP" "$1"

PREFIX="${1##*/}"		# strip leading path
PREFIX="${PREFIX//[$FILTER]/_}" # replace some chars with _
PREFIX="${PREFIX%%.zip}_"   	# replace trailing .zip with _

for bbfile in `ls "$TEMP" | sed "s/^$PREFIX//"`; do
	studnr=${bbfile%%_*}    # clip trailing
	studnr=${studnr%%.txt}	# might be a description file (ugly)
	basename=${bbfile##${studnr}_}
	mkdir -p "$studnr"
	mv "$TEMP/$PREFIX${bbfile}" "${studnr}/${basename}"
done

rmdir "$TEMP"

