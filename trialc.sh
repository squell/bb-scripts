#! /bin/sh

for cmd in g++
do
	if ! command -v $cmd >/dev/null 2>&1
	then
		echo "Who am I? Why am I here? Am I on lilo? $cmd is missing!" >& 2
		exit 1
	fi
done

if [ -z "$1" ]; then
	echo "usage: trialc.sh dir" 1>&2
	exit
fi

CXX="g++ -std=c++0x -fsyntax-only -Wall -Wextra -pedantic"

MYDIR="${0%/*}"

progbar() {
	progress="${progress}#"
	echo -n "!processed $(echo -n "$progress" | wc -c)/$1" | tr '!' '\r'
}

for dir in "$@"; do
	progbar "$#"
	for f in "$dir"/*.[Cc] "$dir"/*.[Cc][Pp][Pp]; do
		test -e "$f" && $CXX "${f}"
	done 2> "$dir"/gcc.log
	"$MYDIR/jarify.sh" "$dir" 2> "$dir"/java.log
	for log in "$dir"/gcc.log "$dir"/java.log; do
		test -s "$log" || rm -f "$log"
	done
done
echo
