#! /bin/bash

# - levert feedback per mail
# - automatiseert invoeren van grades naar Bb

set -e

MYDIR="${0%/*}"

if [ ! -e "$MYDIR"/userlist ]; then
	echo Harvesting email addresses
	"$MYDIR"/getsch.sh users > "$MYDIR"/userlist || (echo "FAIIIL"; rm "$MYDIR"/userlist; exit 1)
fi

if [ ! -e "${1:+$1/}grades.csv" ]; then
	echo Where is "${1:+$1/}grades.csv?"
	exit
fi

echo May spam.
for fulldir in "${1:+$1/}"s*; do
	dir="${fulldir##*/}"
	echo "$dir"
	"$MYDIR"/mailto.sh "${fulldir}/${dir}.txt"
	"$MYDIR"/grades.sh "${fulldir}/${dir}.txt" >> "${1:+$1/}grades.csv"
done

echo Supply your Bb login, or upload "${1:+$1/}grades.csv" manually.
"$MYDIR"/upload.sh "${1:+$1/}grades.csv"
