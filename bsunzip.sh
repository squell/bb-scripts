#! /bin/sh

# unzip a brightspace-provided file, and split the index.html it contains over the subdirectories

umask 077

if [ -z "$1" ]; then
	echo "Usage: bsunzip.sh bestand.zip [destination folder]"
	exit 1
fi

if [ ! -e "$1" ]; then
	echo "Could not find $1"
	exit 2
fi

DEST="${2:-.}"

if [ ! -e "$DEST" ]; then
	mkdir -p "$DEST" || exit 3
fi

for sub in "$DEST"/*/; do
	[ "$sub" = "$DEST/*/" ] && break
	echo "Destination already contains subdirectories! I am refusing to create a mess."
	exit 4
done

unzip -q -o -d "$DEST" "$1"

ADDED="#comments.txt"

getcomment() {
	tr -d '\n' < "$DEST"/index.html | sed 's/<tr bgcolor=#AAAAAA>/\n&/g' | grep -F "$1" | grep -F "$2"
}

for submission in "$DEST"/*/; do
        [ "$submission" = "$DEST/*/" ] && exit
        date="${submission%/}"
	surname="${date% -*}"
	surname="${surname##* }"
        date="${date##*- }"
	if getcomment "$date" "$surname" | grep -F -e '<script'  -e '<style'; then
		echo "$submission: contains suspicious tags!"
		echo "We need to talk:" >  "$submission/NOT_APPRECIATED.TXT"
		getcomment "$date" "$surname" >> "$submission/NOT_APPRECIATED.TXT"
	fi
	getcomment "$date" "$surname" | html2text -nobs | sed '1d' > "${submission}${ADDED}"
	touch -r "$DEST"/index.html "${submission}${ADDED}"
done
rm -f "$DEST"/index.html
