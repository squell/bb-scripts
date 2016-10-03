#! /bin/bash

# ---------------------- configuratie ------------------------#

BBUSER=s0620866
BBCOURSEID=91125

typeset -A email
email[marc]="mschool@science.ru.nl"
email[ko]="kostoffelen@student.ru.nl"
email[pol]="p.vanaubel@student.science.ru.nl"

SUBJECT="1314 Functioneel Programmeren (NWI-IBC006-2013-KW1-V):"

# ---------------------- end of config -----------------------#

# dit script regelt de verdeling over de assistenten,
# en het downloaden van BB (dat laatste kan ook met de hand)

set -e

export BBUSER BBCOURSEID

MYDIR="${0%/*}"
PATH="${PATH}:${MYDIR}"

for ta in "${!email[@]}"; do
	if [ ! -z "`ls "$ta" 2>/dev/null`" ]; then
		echo $ta exists. Clean up first.
		exit
	fi
done

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

echo Trying to adjust for student creativity.
antifmt.sh

echo 
echo Trial compilation
trialc.sh [sez][0-9]*    # reminder: this also matches 's0abc' etc.

echo Groupcheck 
groepjes.sh [sez][0-9]* | grep "<with>" || true

echo

# first read a list of students that are assigned fixed ta's (group_$name); the format of this file
# can be the same as the userlist-file, but only the first column matters
for ta in "${!email[@]}"
do
    listfile="$MYDIR/group_${ta}"
    test -e "$listfile" || continue
    echo "Distributing workload to $ta"
    mkdir -p "$ta"
    while read stud trailing; do
	[ -e "$stud" ] && mv "$stud" "$ta"
    done < "$listfile"
done

echo Randomly distributing workload 

hak2.sh "${!email[@]}" 

humor=$(iching.sh)
for ta in "${!email[@]}"
do
    cp grades.csv "$ta"
    cp userlist "$ta"
    cp -n bblogin2.sh feedback.sh grades.sh pol.sh stats.sh "$ta"
    sed -f - upload.sh > "${ta}/upload.sh" <<...
/^BBCOURSEID=/c\
BBCOURSEID=$BBCOURSEID
...
    sed -f - mailto.sh > "${ta}/mailto.sh" <<...
/^FROM=/c\
FROM="${email[$ta]}"
/^PREFIX=/c\
PREFIX="$SUBJECT"
...
    chmod +x "${ta}"/mailto.sh "${ta}"/upload.sh
    if [ "${email[$ta]}" != "" ]; then
	echo Mailing "$ta"
	pkt="$ta-${zip%.zip}.7z"
	7za a -ms=on -mx=9 "$pkt" "$ta" > /dev/null
	#echo "$humor" | mailx -n -s "${SUBJECT} ${zip%.zip}" -a "$pkt" "${email[$ta]}" 
	echo "$humor" | mutt -s "${SUBJECT} ${zip%.zip}" -a "$pkt" -- "${email[$ta]}" 
	rm -f "$pkt"
    fi
done

