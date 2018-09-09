#! /bin/sh

# - sends provided feedback by email
# - streamlines grade submission in Brightspace

set -e

MYDIR="${0%/*}"

if [ ! -e "grades.csv" ]; then
	echo "Where is grades.csv?" >&2
	exit
fi

feedback="$1"

if [ -z "$feedback" ]; then
	echo "Usage: feedback.sh report.txt" >&2
	exit
fi

echo May spam.
for fulldir in */; do
	report="${fulldir}${feedback}"
	if ! [ -f "$report" ]; then
		echo "$report not found!" >&2
		exit
	fi
	echo "$fulldir"
	"$MYDIR"/mailto.sh "$report"
	"$MYDIR"/grades.sh "$report" >> "grades.csv"
done

echo You can now upload grades.csv manually.
