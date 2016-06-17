#! /bin/bash

# create a emulated s123456 directory + fake response file
# use if someone who submitted manually :(

# Usage: ./mksdir.sh "Student One" "Student Two"
# works for any number of students.

set -e

if [ -e "grades.csv" ]; then
	ASSIGNMENT=$(cat grades.csv)
	ASSIGNMENT=${ASSIGNMENT#*\"}
	ASSIGNMENT=${ASSIGNMENT%|*}
else
	echo Please select an assignment first.
	exit 1
fi

NAMELINES=

for NAME in "$@"; do
	TMP="${NAME##* }"
	select name in $(grep -i "$TMP" "${0%/*}/userlist" | tr '\t' '|'); do
		DIR="$(echo "$name" | cut -f1 -d'|')"
		break
	done

	if [ -z "$DIR" ]; then
		echo "User $NAME not found."
		continue
	fi

	if [ -e "$DIR" ]; then
		echo "$DIR" already exists!
		continue
	fi

	NAMELINES+="Name: $NAME ($DIR)"$'\n'

	echo "creating $DIR"
	mkdir -p "$DIR"
	cat >> "$DIR/$DIR.txt" <<EOF
	${NAMELINES}Assignment: $ASSIGNMENT
	Date Submitted: $(date)
	Current Grade: Needs Grading
	
EOF

	unset DIR
done
