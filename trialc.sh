#! /bin/sh

if [ -z "$1" ]; then
	echo "usage: trialc.sh dir"
	exit
fi

CXX="g++ -std=c++0x -fsyntax-only -Wall -Wextra -pedantic"

MYDIR="${0%/*}"

for dir in "$@"; do
	for f in `ls "$dir"/*.[Cc] "$dir"/*.[Cc][Pp][Pp] 2> /dev/null`; do
		$CXX "${f}" 2> "$dir"/gcc.log
	done
	"$MYDIR/jarify.sh" "$dir" 2> "$dir"/java.log
done
