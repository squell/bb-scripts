#! /bin/bash

# TODO: 
# - distribution of csv files to TA's is not currently handled
#   what is blocking: figure out the best way to enter grades
# - groepcheck is disabled
#   what is blocking: figure out the best way to handle grades/feedback in bs
#   for the user(s) that did not submit the original file
# - assigning students to fixed TA's
#   what is blocking: figure out how to use group info provided by BrightSpace

# ---------------------- configuratie ------------------------#

typeset -A email
email[marc]="mschool@science.ru.nl"
#email[ko]="kstoffelen@science.ru.nl"
#email[pol]="paubel@science.ru.nl"

SUBJECT="`whoami` could not be bothered to configure $SUBJECT"

# ---------------------- end of config -----------------------#

# this script takes care of the distribution of workload over
# all the teaching assistants, after downloading the zip

set -e

MYDIR="${0%/*}"
PATH="${PATH}:${MYDIR}"

for ta in "${!email[@]}"; do
	if [ ! -z "`ls "$ta" 2>/dev/null`" ]; then
		echo $ta exists. Clean up first.
		exit
	fi
done

for zip in *.zip; do
	if [ "$zip" != "*.zip" ]; then
		echo Ah. What file should I use?
		select zip in *.zip; do
			test ! -e "$zip" && continue
			echo Unbrightspacing "$zip"
			"$MYDIR"/bsunzip.sh "$zip"
			break
		done
		break
	fi
	unset zip
done
assignment="${zip%%Download*}"

if [ -z "$zip" ]; then
	echo Please download a .zip before trying to distribute one.
	exit 37
fi

echo Trying to adjust for student creativity.
"$MYDIR"/antifmt.sh */

echo 
echo Trial compilation
"$MYDIR"/trialc.sh */

echo
echo Doing a rough plagiarism check
"$MYDIR"/dupes.sh */

#echo Groupcheck 
#"$MYDIR"/groepjes.sh */ | grep "<with>" || true

echo

# first read a list of students that are assigned fixed ta's (group_$name); the format of this file
# can be the same as the userlist-file, but only the first column matters
#for ta in "${!email[@]}"
#do
#    listfile="$MYDIR/group_${ta}"
#    test -e "$listfile" || continue
#    echo "Distributing workload to $ta"
#    mkdir -p "$ta"
#    while read stud trailing; do
#	[ -e "$stud" ] && mv "$stud" "$ta"
#    done < "$listfile"
#done

echo Randomly distributing workload 
"$MYDIR"/hak3.sh "${!email[@]}" 

humor=$(iching.sh)
for ta in "${!email[@]}"
do
    #cp grades.csv "$ta"
    cp -n "$MYDIR"/{pol.sh,rgrade.sh,collectplag.sh} "$ta"
    sed -f - "$MYDIR"/mailto.sh > "${ta}/mailto.sh" <<...
/^FROM=/c\
FROM="${email[$ta]}"
/^PREFIX=/c\
PREFIX="${SUBJECT}: $assignment"
...
    chmod +x "${ta}"/mailto.sh
    if [ "${email[$ta]}" != "" ]; then
	echo Mailing "$ta"
	pkt="$ta-${zip%.zip}.7z"
	7za a -ms=on -mx=9 "$pkt" "$ta" > /dev/null
	#echo "$humor" | mailx -n -s "${SUBJECT} ${zip%.zip}" -a "$pkt" "${email[$ta]}" 
	echo "$humor" | mutt -s "${SUBJECT}: ${zip%.zip}" -a "$pkt" -- "${email[$ta]}" 
	rm -f "$pkt"
    fi
done
