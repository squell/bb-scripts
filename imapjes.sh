#! /bin/bash

FOLDER="INBOX.Test"
SERVER="imaps://imap.science.ru.nl"
MUNPACK="./munpack"

MYDIR="${0%/*}"
umask 077

# nicely ask the credentials from user
if [ -z "$IMAPUSER" ]; then
	read -p "IMAP User: " IMAPUSER
fi
read -p "IMAP Password: " -s PASSWORD
echo

netrc() {
	builtin echo "machine imap.science.ru.nl login $USER password $PASSWORD"
}

imap_check() {
	curl -s -m10 --netrc-file <(netrc) "${SERVER}/${FOLDER}" > /dev/null
}

imap_dir() {
	curl -s -m10 --netrc-file <(netrc) "${SERVER}/${FOLDER}" --request "SEARCH UNSEEN" | tr -cd ' [0-9]'
}

imap_fetchhdr() {
	curl -s -m10 --netrc-file <(netrc) "${SERVER}/${FOLDER};UID=$1;SECTION=HEADER.FIELDS%20(FROM%20SUBJECT)"
}

imap_fetch() {
	curl -s -m10 --netrc-file <(netrc) "${SERVER}/${FOLDER};UID=$1"
}

if ! imap_check; then
	echo 1>&2 'Could not acess IMAP folder; check your configuration or password!'
	exit 1
fi

for msg in $(imap_dir); do
	echo "retrieving message $msg"
	dir="IMAP/$msg"
	response="$dir/$msg.txt"
	mkdir -p "$dir"
	imap_fetchhdr "$msg" | tr -d $'\r' > "$response"
	imap_fetch "$msg" | $MUNPACK -q -t -C "$dir" 2> /dev/null | sed -n '/^Did not find anything to unpack from standard input$/q;s/^/+ /p' | grep '' || imap_fetch "$msg" > "$dir/part1"
	{ cat - "$dir"/part[1-9] <<EOF
Current Grade: Needs Grading
Message:
EOF
	  rm "$dir"/part[1-9]; } | tr -d $'\r' >> "$response"
done
echo "fetching mail completed"
