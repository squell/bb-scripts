#! /bin/sh

if [ -z "$*" ]; then
	echo "Usage: grades.sh s[0-9]*/s[0-9]*.txt" >& 2
	exit
fi

USERLIST="${0%/*}/userlist"

if [ ! -e "$USERLIST" ]; then
        echo Cannot find "$USERLIST" file >& 2
        exit
fi

for file in "$@"; do
        TOID=`sed -n '/^Name:/s/.*\(s[0-9]\{7\}\).*/\1/p' "$file"`
	#TOID=`grep -o '\<s\?[0-9]\{7\}\>' "$file" | tr -d 's' | sort -u`
	#TOID=`grep -ohI '\<s\?[0-9]\{7\}\>' "${file%%/*}"/* | tr -d 's' | sort -u`
	GRADE=`sed -n '/^Current Grade:[[:space:]]*/s///p' "$file"`

	for id in $TOID; do
		if [ "$GRADE" ] && grep -q "$id" "$USERLIST"; then
			GRADE="${GRADE##0*}"
			echo "$id,${GRADE:-0.000001}"
		fi
	done
done

