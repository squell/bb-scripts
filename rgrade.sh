#!/bin/bash

# Start grading in a randomly chosen, ungraded submission folder

[ $# != 0 ] &&  ACTION="$@" || ACTION="${SHELL:-bash}"

if [ "$(pgrep 'rgrade.sh')" != "$$" ]; then
	echo "You are already grading this submission, please return to it:"
	echo "$RGRADE_DIR"
	exit 1
fi

todo() {
	ls -d */.todo 2> /dev/null | sed 's:/.todo::'
}

DIR="$(todo | shuf -n1)"
if [ -z "$DIR" ]; then
	echo "It seems like you are not currently grading anything; do you want to start now?"
	select reply in yes no; do
		reply="${reply:-${REPLY,,}}"
		if [ "${reply%%y*}" = "" ]; then
			for dir in */; do
				if [ "$dir" = "*/" ]; then
					echo "... there is nothing here to grade!"
					exit 1
				fi
				touch "${dir}.todo"
			done
			DIR="$(todo | shuf -n1)"
			break
		else
			echo "A wise choice."
			exit
		fi
	done
fi

if [ -n "$DIR" ]; then
	[ $# != 0 ] || echo "Type 'exit' to finish grading; use 'exit 1' to abort grading the current submission."
	echo "Entering $DIR."
	(cd "$DIR" && export RGRADE_DIR="`pwd`" && $ACTION) && rm -f "$DIR"/.todo
	count="$(todo | wc -l)"
	if [ "$count" = 0 ]; then
		echo "Exiting $DIR. You have finally finished!"
	else
		echo "Exiting $DIR. Still $count to go..."
	fi
else
	(base64 -d | gunzip) <<-EOF
	H4sIANgxkVsCA1WOMQrEMAwEe79icSMXkdRHXzHouoO0ae/xtxYkJAvGywyWBWwIHsBUeu+ixl6s
	scz5cyrBFaEm8yUxNdTxTJFy7pzxTnBcK5UZ2O0WFojMkh9dmWJcZEXZvJi0xxJiarolb+Lje15i
	AGM9aq+PheAPNske4ukAAAA=
	EOF
fi
