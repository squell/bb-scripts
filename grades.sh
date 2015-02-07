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
        TOID=`sed -n '/^Name:/s/.*\([sez][0-9]\+\).*/\1/p' "$file"`
	GRADE=`sed -n '/^Current Grade:[[:space:]]*/s///p' "$file"`

	for id in $TOID; do
		if [ "$GRADE" ] && grep -q "$id" "$USERLIST"; then
			GRADE="${GRADE##0*}"
			echo "$id,${GRADE:-0.000001}"
		fi
	done
done

