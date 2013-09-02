#! /bin/bash

# sanity check op hoe mensen hun partners vermelden

USERLIST="${0%/*}/userlist"

if [ -z "$*" ]; then
	echo "Usage: check.sh s[0-9]*" >& 2
	exit
fi

if [ ! -e "$USERLIST" ]; then
	echo Cannot find "$USERLIST" file >& 2
	exit
fi

for dir in "$@"; do
	if [ ! -e "$dir" ]; then
		echo "$dir" not found. >& 2
		exit 1
	fi

	TOID1=`grep -o '\<s\?[0-9]\{7\}\>' "$dir/$dir.txt" | tr -d 's' | sort -u`
	TOID2=`grep -ohI '\<s\?[0-9]\{7\}\>' "$dir"/* | tr -d 's' | sort -u`

	(grep "$dir" "$USERLIST" || echo "s$id [null]") | tr '\t\n' '  '  | sed 's/@[[:print:]]*//g'
	echo -n " <forgot> "
	(for id in $TOID1; do
		(grep "$id" "$USERLIST" || echo "s$id [null]") | tr '\t' ' ' | sed 's/@[[:print:]]*//g'
	done ;
	for id in $TOID2; do
		(grep "$id" "$USERLIST" || echo "s$id [null]") | tr '\t' ' ' | sed 's/@[[:print:]]*//g'
	done) | sort | uniq -u
	echo -n $'\r'

	(grep "$dir" "$USERLIST" || echo "s$id [null]") | tr '\t\n' '  ' | sed 's/@[[:print:]]*//g'
	for id in $TOID1; do
		grep -q "$id" "$USERLIST" || echo " <unregistered> s$id" | sed 's/@[[:print:]]*//g'
	done
	echo -n $'\r'
done

echo -n $'\e[K'
