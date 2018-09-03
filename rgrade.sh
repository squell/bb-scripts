#!/bin/sh

# Start grading in a randomly chosen, ungraded submission folder
[ $# != 0 ] &&  ACTION="$@" || ACTION="${SHELL:-bash}"

if [ "$(pgrep 'rgrade.sh')" != "$$" ]; then
	echo "You are already grading this submission, please return to it:"
	echo "$RGRADE_DIR"
	exit 1
fi

todo() {
	ls -d */.seen */ 2> /dev/null | sed 's:/.*::' | uniq -u
}

DIR="$(todo | shuf | head -n1)"
if [ -n "$DIR" ]; then
	[ $# != 0 ] || echo "Type 'exit' to finish grading; use 'exit 1' to abort grading the current submission."
	echo "Entering $DIR."
	(cd "$DIR" && export RGRADE_DIR=`pwd` && $ACTION) && touch "$DIR"/.seen
	count="$(todo | wc -l)"
	if [ "$count" = 0 ]; then
		echo "Exiting $DIR. You have finally finished!"
	else
		echo "Exiting $DIR. Still $count to go..."
	fi
else
	echo "Nothing to do! Grab a beer."
fi
