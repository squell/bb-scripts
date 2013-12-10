#! /bin/bash

# regelt de verdeling over de assistenten,
# en het download van BB (als je wil)

declare -A email
email[marc]="mschool@science.ru.nl"
email[ko]="kostoffelen@student.ru.nl"
email[pol]="p.vanaubel@student.science.ru.nl"

SUBJECT="[A&D]"

set -e

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
trialc.sh s* 

echo Groupcheck 
groepjes.sh s* | grep "<with>" || true

echo
echo Balancing workload 

hak2.sh "${!email[@]}" 

humor=$(iching.sh)
for ta in "${!email[@]}"
do
    cp grades.csv "$ta"
    cp userlist "$ta"
    cp -n bblogin2.sh upload.sh "$ta"
    cp -n feedback.sh grades.sh "$ta"
    sed < mailto.sh > "${ta}/mailto.sh" "/^FROM=/c\
FROM=${email[$ta]}"
    chmod +x "${ta}"/mailto.sh
    if [ "${email[$ta]}" != "" ]; then
	echo Mailing "$ta"
	pkt="$ta-${zip%.zip}.7z"
	7za a -ms=on -mx=9 "$pkt" "$ta" > /dev/null
	#echo "$humor" | mailx -n -s "${SUBJECT} ${zip%.zip}" -a "$pkt" "${email[$ta]}" 
	echo "$humor" | mutt -s "${SUBJECT} ${zip%.zip}" -a "$pkt" -- "${email[$ta]}" 
	rm -f "$pkt"
    fi
done

