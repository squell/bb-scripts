#! /bin/bash

# regelt de verdeling over de assistenten,
# en het download van BB (als je wil)

declare -A email
email[marc]="m.schoolderman@student.science.ru.nl"
email[thom]="functioneelprogrammereniscool@thomwiggers.nl"
email[tom]="mijnemailadresiscooler@tomsanders.nl"

SUBJECT="[FP]"

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
trial.sh s* > /dev/null

echo Groupcheck 
groepjes.sh s* | grep "<with>" || true

echo Received `find s* -name "*.icl" | wc -l` programs in `ls -d s* | wc -l` submissions by `cat s*/s*.txt | grep -hc ^Name:` students.
echo Found `find s* -name "*.ERROR" | wc -l` compilation goofs. Tsk tsk.
echo Tested `grep 'Passed after [0-9]\+ tests' s*/gast_results.txt | wc -l` programs with flying colors.
echo Had to put `grep '*** killed' s*/gast_results.txt | wc -l` out of their misery.
rm -f s*/Clean\ System\ Files/*
rmdir s*/Clean\ System\ Files

echo
echo Fraud check 1
plaggen.sh s* > /dev/null

echo Fraud check 2
dupes.sh s* > /dev/null

echo
echo Balancing workload 

hak2.sh "${!email[@]}"

humor=$(boeket.sh)
#humor=$(iching.sh)
for ta in "${!email[@]}"
do
    cp grades.csv "$ta"
    cp userlist "$ta"
    cp pol.sh "$ta"
    cp -n hanno.sh grades.sh "$ta"
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

