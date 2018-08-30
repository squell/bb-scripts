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

for submission in "$DEST"/*/; do
	[ "$submission" = "$DEST/*/" ] && exit
	date="${submission%/}"
	date="${date##*- }"
	if [ -e "$submission"/comments.txt ]; then
		nonce="-`shuf -i 1-10000 -n1`"
	else
		nonce=""
	fi
	grep "$date" "$DEST"/index.html | html2text | sed '1d' > "$submission"/comments"$nonce".txt
done
rm -f "$DEST"/index.html
