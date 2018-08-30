#!/bin/sh

echo "rgrade.sh is disabled while we transition to a new bright space"
exit

# Start grading a randomly chosen, ungraded submission
[ $# != 0 ] &&  SHELL="$@" || ([ -z "$SHELL" ] && SHELL=bash)
PAT="Needs Grading"
GLB='./[usezf][0-9]*/[usezf][0-9]*.txt'
DIR="$(grep -Fl "$PAT" $GLB | shuf | head -1)"
if [ -n "$DIR" ]; then
	OPWD="$(pwd)"
	cd "$(dirname "$DIR")"
	$SHELL
	cd "$OPWD"
fi
echo "$DIR klaar. Nog $(grep -Fl "$PAT" $GLB | wc -l) te gaan..."
