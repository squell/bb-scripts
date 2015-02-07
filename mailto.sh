#! /bin/sh

set -e

FROM=`whoami`@science.ru.nl
BCC="$FROM"

PREFIX="BFCA-IBC001-1A-2011: [A&D]"

USERLIST="${0%/*}/userlist"

if [ -z "$*" ]; then
	echo "Usage: mailto.sh s[0-9]*/s[0-9]*.txt" >& 2
	exit
fi

if [ ! -e "$USERLIST" ]; then
	echo Cannot find "$USERLIST" file >& 2
	exit
fi

for file in "$@"; do
	if [ ! -e "$file" ]; then
		echo "$file" not found. >& 2
		exit 1
	fi

	# correct encoding errors caused by Windows tools
	ENC=`file -b "$file"`
	if [ "$ENC" = "UTF-8 Unicode (with BOM) text" ]; then
		(echo '1s/^.//'; echo wq) | ed -s "$file"
	fi
	if [ "${ENC%% *}" != "UTF-8" ] && [ "${ENC%% *}" != "ASCII" ]; then
		#recode `file -b --mime-encoding "$file"`..utf-8 "$file"
		iconv -c -o "$file" -f `file -b --mime-encoding "$file"` "$file"
	fi

	ASSIGNMENT=`sed -n '/^Assignment:/s///p' "$file"`
	TOID=`sed -n '/^Name:/s/.*\([sez][0-9]\+\).*/\1/p' "$file"`
	GRADE=`sed -n '/^Current Grade:[[:space:]]*/s///p' "$file"`

	if [ "$GRADE" = "Not Yet Graded" ] || ! grep -q "Feedback:" "$file"; then
		echo "$file" grading not finished, stopping >& 2
		exit 1
	fi

	if [ -z "${TOID}" ] || [ -z "${GRADE}" ] || [ -z "${ASSIGNMENT}" ]; then
		echo "$file" does not appear to be a BlackBoard file, stopping >&2
		exit 1
	fi

	SUBJECT="$PREFIX Feedback $ASSIGNMENT"
	MIME="Content-Type: text/plain; charset=utf-8"
	TO=`for id in $TOID; do
		(grep "$id" "$USERLIST" || echo >&2 "$id not registered") | cut -f2 | tr -d '\r'
	done`

	if [ -e "${file}.sent" ]; then
		echo Skipping $TOID. Already mailed to: `cat "${file}.sent"` >&2
	elif [ -z "$TO" ]; then
		echo Could not find any email address for students: $TOID! >&2
		touch "${file}.could_not_sent"
	else
		sed -n '/^Date/p;/^Current Grade:/p;/^Feedback:/,$p' "$file" | tr -d '\r' | mail -a "$MIME" -n -s "$SUBJECT" ${FROM:+-a "From: $FROM"} ${BCC:+-b "$BCC"} $TO && echo "$TO" > "${file}.sent"
		#sed -n '/^Date/p;/^Current Grade:/p;/^Feedback:/,$p' "$file" | tr -d '\r' | "${0%/*}"/xmail.sh -a "$MIME" -s "$SUBJECT" ${FROM:+-f "$FROM"} ${BCC:+-b "$BCC"} $TO && echo "$TO" > "${file}.sent"
	fi
done

