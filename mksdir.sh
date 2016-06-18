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
	NAMELINES+="Name: $NAME ($DIR)"$'\n'
done

if [ -z "$DIR" ]; then
	echo User not found.
	exit 1
fi

if [ -e "$DIR" ]; then
	echo "$DIR" already exists!
	exit 1
fi

echo "creating $DIR"
mkdir -p "$DIR"
cat >> "$DIR/$DIR.txt" <<EOF
${NAMELINES}Assignment: $ASSIGNMENT
Date Submitted: $(date)
Current Grade: Needs Grading

EOF
