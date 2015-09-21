#! /bin/bash

# ---------------------- configuratie ------------------------#

BBUSER=s1234567
BBCOURSEID=...

# ---------------------- end of config -----------------------#

# dit script regelt het printen
# en het downloaden van BB (dat laatste kan ook met de hand)

set -e

# controleer het kerberos ticket, voor de printer...
klist -s || kinit

export BBUSER BBCOURSEID

MYDIR="${0%/*}"
PATH="${PATH}:${MYDIR}"

test -e "$MYDIR/userlist" || getsch.sh users > "$MYDIR/userlist"

for zip in *.zip; do
	if [ "$zip" != "*.zip" ]; then
		echo Ah. What file should I use?
		select zip in *.zip; do
			test ! -e "$zip" && continue
			echo Unblackboardizing "$zip"
			bbfix.sh "$zip"
			break
		done
		break
	fi
	unset zip
done

if [ -z "$zip" ]; then
	getsch.sh
	rm -f bb.cookie
	for zip in *.zip; do
		if [ ! -e "$zip" ]; then
			echo That didn\'t work.
			exit
		fi
		echo Unblackboardizing "$zip"
		bbfix.sh "$zip"
		break
	done
	rm -f "$zip"
fi

prn="$1"
if [ -z "$prn" ]; then
	read -p "Print to (^C skips): " -e -i lazarus prn
fi
echo "Printing to ${prn}..."
printhuiswerk.sh "$prn"
