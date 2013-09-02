#! /bin/bash

# Programming in bash leads to insanity.

set -e

while getopts "f:s:b:h:a:v" flag; do
	case "$flag" in
	'?') exit 1;;
	'f') FROM="$OPTARG";;
	's') SUBJECT="$OPTARG";;
	'b') BCC="$OPTARG";;
	'h') SMTP="$OPTARG";;
	'v') DEBUG="yes";;
	'a') HDR="${HDR:+$HDR$'\n'}$OPTARG";;
	esac
done

DOMAIN=`dnsdomainname`
FROM="${FROM:-${DOMAIN:+`whoami`@$DOMAIN}}"
SMTP="${SMTP:-${DOMAIN:+smtp.$DOMAIN}}"

if ! shift $((OPTIND - 1)) || [[ -z $1 ]] || [[ -z $FROM ]] || [[ -z $SMTP ]]; then
	echo "usage: xmail.sh [-v] [-h server] [-f from-addr] [-b bcc] [-a hdr] to-addr ..."
	exit
fi

die() {
	echo "$@" >& 2
	exit 1
}

smtp() {
	[[ $1 ]] && echo "$1" 1>&${P[1]}
	[[ $DEBUG ]] && echo "<= $1"
	read -u${P[0]} -t10 code ignore || ignore="timeout!"
	[[ $DEBUG ]] && echo "=> $code $ignore"
	[[ $code == ${2:-250} ]] || die "Protocol failure: $ignore"
}

declare -a P

if false; then
	# stdin/stdout
	P[0]=0 
	P[1]=1
elif false; then
	# bash socket
	P[0]=5
	P[1]=5
	exec 5<>"/dev/tcp/$SMTP/25"
else
	# netcat in a coprocess
	coproc P { nc "$SMTP" 25; } 
fi

smtp "" 220
smtp "HELO `uname -n`"
smtp "MAIL FROM: <$FROM>"
[[ -z $BCC ]] || smtp "RCPT TO: <$BCC>"
for to in "$@"; do
	[[ $to =~ @ ]] || to="$to@`dnsdomainname`"
	smtp "RCPT TO: <$to>"
done
smtp "DATA" 354

{
    [[ $FROM ]] && echo "From: $FROM" 
    prefix="To:"
    for to in "$@"; do
	    [[ $to =~ @ ]] || to="$to@`dnsdomainname`"
	    echo -n "$prefix $to"
	    prefix=$',\n\t'
    done
    echo
    [[ $SUBJECT ]] && echo "Subject: $SUBJECT" 
    [[ $HDR ]] && echo "$HDR"
    echo 
    grep -v '^[.]$' 
} 1>&${P[1]}

smtp "."
smtp "QUIT" 221

