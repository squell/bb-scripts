#! /bin/bash

# create a emulated s123456 directory + fake response file
# use if someone who submitted manually :(

# Usage: $ ./mksdir.sh Full Name

set -e

FULLNAME="$@"
NAME="${FULLNAME##* }"
ASSIGNMENT="Week x"

select name in $(grep -i "$NAME" "${0%/*}/userlist" | tr '\t' '|'); do
	DIR=`echo "$name" | cut -f1 -d'|'`
	break
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
Name: $FULLNAME ($DIR)
Assignment: $ASSIGNMENT
Date Submitted: $(date)
Current Grade: Not Yet Graded

EOF
