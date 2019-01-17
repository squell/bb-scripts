#! /bin/sh

# unzip a brightspace-provided file, and split the index.html it contains over the subdirectories

if ! command -v 7za >/dev/null 2>&1; then
	echo "Who am I? Why am I here? Am I on lilo? unzip is missing!" >& 2
	exit 1
elif ! perl -MHTML::Entities -e 'decode_entities($_);' > /dev/null; then
	echo "We need to talk about your perl installation, see above."
	exit 1
fi

umask 077

if [ -z "$1" ]; then
	echo "Usage: bsunzip.sh bestand.zip [destination folder]" 1>&2
	exit 1
fi

if [ ! -e "$1" ]; then
	echo "Could not find $1" 1>&2
	exit 2
fi

DEST="${2:-.}"

if [ ! -e "$DEST" ]; then
	mkdir -p "$DEST" || exit 3
fi

for sub in "$DEST"/*/; do
	[ "$sub" = "$DEST/*/" ] && break
	echo "Destination already contains subdirectories! I am refusing to create a mess." 1>&2
	exit 4
done

# brightspace is apparently configured to interpret the UTF8-encoded
# names it gets from $somewhere as encoded in MS-DOS codepage 866,
# which unzip then converts to UTF8. So we need to undo that.
unmojibake() {
	cvt="$(echo "$1"| iconv --from=utf8 --to=cp866)"
	[ "$cvt" = "$1" ] || mv -n "$1" "$cvt"
}

# however, by running unzip in the POSIX locale, we can circumvent
# this from even becoming a problem, and so the above macro is not called anymore
#(export LC_CTYPE=POSIX; unzip -q -o -d "$DEST" "$1")
# not all systems have an unzip that does not mangle the filenames even with
# the correct locale, therefore we fall back to 7z
7za x -y -bd -o"$DEST" "$1"

ADDED="#comments.txt"

strip_cruft() {
	# 1) remove all line feeds
	# 2) filter out all inner table cells; <td>...</td>, where "..." doesn't contain opening/closing tags starting with a t
	# 3) keep only every 2nd line (which contains the actual comment)
	# 4) eliminate the brightspace HTML boilerplate
	# 5) replace <p></p>, &amp, and <br>
	tr -d '\r\n' | egrep -o '<td[^>]*>([^<]*(<([^/t]|/[^t])[^>]*>)?)*</td>' | sed -n 'n;p;n' |
		sed "s|<td width=80% valign=top>\(.*\)<p style='margin-top:3px;'><b>Comments:</b><br>\(.*\)</td>|\2|" |
		tr -d '\n' | sed 's|<br />|\n|g; s|<p>\([^<]*\)</p>|\1\n|g; s|&amp;|\&|g'

}

# brightspace user comments are put in a quite unusable HTML file
getcomment() {
	tr -d '\n' < "$DEST"/index.html | sed 's/<tr bgcolor=#AAAAAA>/\n&/g' | perl -MHTML::Entities -pe 'decode_entities($_);' | grep -F "$1" | grep -F "$2"
}

for submission in "$DEST"/*/; do
	[ "$submission" = "$DEST/*/" ] && exit
	date="${submission%/}"
	surname="${date% -*}"
	surname="${surname##* }"
	date="${date##*- }"
	comment="$(getcomment "$date" "$surname")"

	# remove the ':' character from the directory name
	sanitized_name="$(echo -n "$submission" | tr ':' '_')"
	mv "$submission" "$sanitized_name"
	submission="$sanitized_name"

	if echo "$comment" | grep -F -e '<script'  -e '<style'; then
		echo "$submission: contains suspicious tags!"
		echo "Report security problems instead of trying to exploit them. Your attempt has been flagged." >  "$submission/WARNING.TXT"
	fi
	echo -n "$comment" | strip_cruft > "${submission}${ADDED}"
	if [ -s "${submission}${ADDED}" ]; then
		touch -r "$DEST"/index.html "${submission}${ADDED}"
	else
		rm -f "${submission}${ADDED}"
	fi
done
rm -f "$DEST"/index.html
