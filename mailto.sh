#! /bin/sh

# this sends the message in dir/file.txt to the addresses in dir/#address.txt

set -e

FROM=`whoami`@science.ru.nl
BCC="$FROM"

PREFIX="OpenCourseWare: "

if [ -z "$*" ]; then
	echo "Usage: mailto.sh dir1/file.txt dir2/file.txt ..." 1>&2
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

	SUBJECT="$PREFIX Feedback $ASSIGNMENT"

	MIME="Content-Type: $(file -b --mime "$file")"

	if [ -e "${file}.sent" ]; then
		echo Skipping $TOID. Already mailed to: `cat "${file}.sent"` >&2
	elif ! TO=`sed 's/.*,//' "$(dirname "$file")/#address.txt"` || [ -z "$TO" ]; then
		echo Could not find any email address to send "$file" to >&2
		touch "${file}.could_not_sent"
	else
		cat "$file" | tr -d '\r' | bsd-mailx -a "$MIME" -n -s "$SUBJECT" ${FROM:+-a "From: $FROM"} ${BCC:+-a "Bcc: $BCC"} ${BCC:+-b "$BCC"} $TO && echo "$TO" > "${file}.sent"
	fi
done

