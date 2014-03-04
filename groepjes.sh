#! /bin/sh

USERLIST="${0%/*}/userlist"

if [ -z "$*" ]; then
	echo "Usage: groepjes.sh s[0-9]*/s[0-9]*.txt" >& 2
	exit 1
fi

if [ ! -e "$USERLIST" ]; then
	echo Cannot find "$USERLIST" file >& 2
	exit 1
fi

addid() {
	echo "1a"
	for id in $TOID; do
		if [ "${id}.txt" != "${file##*/}" ]; then
			grep "$id" "$USERLIST" | sed 's/\(.*\)\t\(.*\)@.*/Name: \2 (\1)/g'
		fi
	done | sort -u
	echo "."
	echo "wq"
}

for dir in "$@"; do
	file="${dir}/${dir##*/}.txt"
	if [ ! -e "$file" ]; then
		echo "$file" not found. >& 2
		exit 1
	fi

	# 1) select only id's specified by the response file
	# 2) select (what looks like) studentnr's contained in the response file
	# 3) select (what looks like) studentnr's in any submitted file

	# is user mentions a studentnr without prefix, s- is assumed.

	#TOID=`sed -n '/Name:/s/.*\([sez][0-9]\+\).*/\1/p' "$file"`
	#TOID=`grep -oi '\<[sez]\?[0-9]\{6,7\}\>' "$file" | tr SEZ sez | sort -u`
	TOID=`grep -oihI '\<[sez]\?[0-9]\{6,7\}\>' "${file%%/*}"/* | sed 's/\<[0-9]/s&/' | tr SEZ sez`
	for id in $TOID; do
		grep "$id" "$USERLIST" | cut -f1,2 | sed 's/@[[:print:]]*\>//g'
	done | sort -u | tr '\t\n' ' ' | sed 's/[^0-9] \</&<with> /g'
	echo

	#continue
	addid | ed -s "$file"
done

