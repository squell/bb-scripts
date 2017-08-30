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

imap_dir() {
	curl -s -m10 --netrc-file <(netrc) "${SERVER}/${FOLDER}" --request "SEARCH UNSEEN" | tr -cd ' [0-9]'
}

imap_fetchhdr() {
	curl -s -m10 --netrc-file <(netrc) "${SERVER}/${FOLDER};UID=$1;SECTION=HEADER.FIELDS%20(FROM%20SUBJECT)"
}

imap_fetch() {
	curl -s -m10 --netrc-file <(netrc) "${SERVER}/${FOLDER};UID=$1"
}

for msg in $(imap_dir); do
	echo "retrieving message $msg"
	dir="IMAP/$msg"
	mkdir -p "$dir"
	imap_fetch "$msg" | $MUNPACK -q -t -f -C "$dir" 2> /dev/null | sed -n '/^Did not find anything to unpack from standard input$/q;s/^/+ /p' | grep '' || imap_fetch "$msg" > "$dir/email.txt"
	imap_fetchhdr "$msg" > "$dir/msgid"
done
