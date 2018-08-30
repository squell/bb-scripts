#!/bin/bash

# Run unit tests

SUITE=../FP1-guru/programs/testsuite
GHC="ghc -i../../FP1-guru/handout"
SUFFIX=Test.hs
TIMEOUT=10

if [ -z "$1" ]; then
	echo "usage: $0 dir"
	exit
fi

hstest() {
	if [ -f "$SUITE/$2$SUFFIX" ]; then
		cp "$SUITE/$2$SUFFIX" "$1"
		cd "$1"
		log="$2".test_results
		rm -f "$log"
		testprog="$2$SUFFIX"
		testmod="${testprog/.hs/}"
		testout="$testmod.out"
		if $GHC -main-is "$testmod" "$testprog" -o "$testout" &>> "$log"; then
			echo >> "$log"
			setsid bash -c "(./\"$testout\" || echo '*** aborted') |& sed 's/^.*\\x8//' &>> \"$log\"" & pid=$!
			sleep $TIMEOUT && kill -9 "-$(ps -o pgid= $pid)" & w=$!
			if wait $pid; then
				kill -9 $w
			else
				echo "*** killed" >> "$log"
			fi
			rm "$testout"
		fi
		cd ..
	fi
}

for dir in "$@"; do
	for f in "$dir"/*.lhs "$dir"/*.hs; do
		[ -f "$f" ] || continue
		hstest "$dir" "$(basename "$f" | sed -e 's/\.l\?hs$//g')"
	done
done
