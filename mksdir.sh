#! /bin/bash

# create a emulated s123456 directory + fake response file
# use if someone who submitted manually :(

set -e

NAME="$1"

select name in $(grep -i "$NAME" "${0%/*}/userlist" | tr '\t' '|'); do
	DIR=`echo "$name" | cut -f1 -d'|'`
	break
done

if [ -e "$DIR" ]; then
	echo "$DIR" already exists!
	exit 1
fi

if [ -z "$DIR" ]; then
	echo User not found.
	exit 1
fi

if [ -z "$DIR" ]; then
	echo Aborted.
	exit 1
fi

echo "creating $DIR"
mkdir -p "$DIR"
cat >> "$DIR/$DIR.txt" <<EOF
Name: $NAME ($DIR)
Assignment:Week x
Date Submitted:$(date)
Current Grade:Not Yet Graded

Submission Field:
gesubmit per email
Files:
$*
EOF
