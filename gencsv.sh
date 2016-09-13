#! /bin/bash

# generate csv output usable for upload

set -e

choose() {
    name=""
    if [ "$#" = 1 ]; then
	name="$1"
    else
	select name; do
	    break
	done
    fi
    test "$name" && echo "> $name" 1>&2
    return
}

while read -p "Student: "; do
    test "$REPLY" || exit
    if choose $(grep -i -F "$REPLY" "${0%/*}/userlist" | tr '\t' '|') && read -p "Grade: " grade; then
	DIR=`echo "$name" | cut -f1 -d'|'`
	echo "$DIR,$grade"
    else
	echo Bzzzzzt. 1>&2
    fi
    echo 1>&2
done
