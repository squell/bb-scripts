#! /bin/bash

# ---------------------- configuratie ------------------------#

BBUSER=s0620866
BBCOURSEID=91125

declare -A email
email[marc]="m.schoolderman@student.science.ru.nl"
email[thom]="functioneelprogrammereniscool@thomwiggers.nl"
email[tom]="mijnemailadresiscooler@tomsanders.nl"

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
trial.sh [sez][0-9]* > /dev/null

echo Groupcheck 
groepjes.sh [sez][0-9]* | grep "<with>" || true

echo Received `find s* -name "*.icl" | wc -l` programs in `ls -d s* | wc -l` submissions by `cat s*/s*.txt | grep -hc ^Name:` students.
echo Found `find s* -name "*.ERROR" | wc -l` compilation goofs. Tsk tsk.
echo Tested `cat s*/gast_results.txt | grep 'Passed after [0-9]\+ tests' | wc -l` programs with flying colors.
echo Had to put `cat s*/gast_results.txt | grep '*** killed' | wc -l` out of their misery.
rm -f s*/Clean\ System\ Files/*
rmdir s*/Clean\ System\ Files

echo
echo Fraud check 1
plaggen.sh s* > /dev/null

echo Fraud check 2
dupes.sh s* > /dev/null

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

humor=$(ambrose.sh)
#humor=$(iching.sh)
for ta in "${!email[@]}"
do
    cp grades.csv "$ta"
    cp userlist "$ta"
    cp pol.sh "$ta"
    cp -n bblogin2.sh "$ta"
    cp -n hanno.sh grades.sh "$ta"
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

