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

SUBJECT="`whoami` could not be bothered to configure SUBJECT"

# ---------------------- end of config -----------------------#

# this script takes care of the distribution of workload over
# all the teaching assistants, after downloading the zip

for cmd in 7za mutt; do
        if ! command -v $cmd >/dev/null 2>&1; then
                echo "Who am I? Why am I here? Am I on lilo? $cmd is missing!" >& 2
                exit 1
        fi
done

shopt -s nullglob
set -e

MYDIR="${0%/*}"
PATH="${PATH}:${MYDIR}"

# first check whether the working dir is clean
for ta in "${!email[@]}"; do
        if [ -d "$ta" ]; then
                echo $ta exists. Clean up first.
                exit
        fi
done

# check if we have a CSV file from brightspace
CSV=""
for csv in *.csv; do
        echo "Assuming student info is in $csv"
        if [ "$CSV" ]; then
                echo "Please select which .csv file to use."
                CSV=""
                select csv in *.csv; do
                        test ! -e "$csv" && continue
                        CSV="$csv"
                        break
                done
                break
        fi
        CSV="$csv"
done

# this macro does quote handling for CSV
csv_to_tab() {
        sed -nr ':l;$s/([^,"]*("[^"]*")?),/\1\t/gp;N;bl'
}

if [ "$CSV" ]; then
        echo "Which grade are we determining?"
        grade=$(
                IFS=$'\n'
                select column in `head -n1 "$CSV" | csv_to_tab | tr '\t' '\n' | grep 'Points Grade' | sed 's: *<[^>]*> *::g' | tr -d \"`; do
                        echo "$column"
                        break
                done
        )
fi

# select the ZIP file (we always ask the user!)
for zip in *.zip; do
        echo "Which .zip file contains the assignments?"
        zip=""
        select zip in *.zip; do
                test ! -e "$zip" && continue
                echo Unbrightspacing "$zip"
                "$MYDIR"/bsunzip.sh "$zip"
                break
        done
        break
done
assignment="${zip%%Download*}"

if [ -z "$zip" ]; then
        echo Please download a .zip before trying to distribute one.
        exit 37
fi

# ----- from this point on everything is automatic -----#

echo Trying to adjust for student creativity.
"$MYDIR"/antifmt.sh */

if [ "$CSV" ]; then
        echo Identifying submissions
        "$MYDIR"/identify.sh "$CSV" */
fi

echo 
echo Trial compilation
"$MYDIR"/trialc.sh */

echo
echo Doing a rough plagiarism check
"$MYDIR"/dupes.sh */

echo

test "${!email[*]}"

# since identify.sh identified groups: see if these match the names of TA's
# and move assignments there...
for ta in "${!email[@]}"; do
    mkdir -p "$ta"
    progbar=""
    for file in */"#group:$ta"; do
        echo -n "Distributing assigned workload to $ta: `echo $progbar | wc -c`" $'\r'
        progbar="$progbar#"
        rm -f "$file"
        mv "${file%#group:$ta}" -t "$ta"
    done
    test "$progbar" && echo
done

dirs=(*/)
echo Randomly distributing unassigned workload  "($((${#dirs[@]} - ${#email[@]})))"
"$MYDIR"/hak3.sh "${!email[@]}" 

# now we have divided the workload, send it out to the ta's
humor=$(iching.sh)
for ta in "${!email[@]}"
do
    cp -n "$MYDIR"/{pol.sh,rgrade.sh,collectplag.sh} "$ta"
    if [ "$CSV" ]; then
        echo "OrgDefinedId,$grade,End-of-Line Indicator" > "$ta/grades.csv"
        cp -n "$MYDIR"/{grades.sh,feedback.sh} "$ta"
        sed -f - "$MYDIR"/mailto.sh > "${ta}/mailto.sh" <<-...
            /^FROM=/c\
            FROM="${email[$ta]}"
            /^PREFIX=/c\
            PREFIX="${SUBJECT}: $assignment"
	...
        chmod +x "${ta}"/mailto.sh
    fi
    if [ "${email[$ta]}" ]; then
        echo Mailing "$ta"
        pkt="$ta-${zip%.zip}.7z"
        7za a -ms=on -mx=9 "$pkt" "$ta" > /dev/null
        #echo "$humor" | mailx -n -s "${SUBJECT} ${zip%.zip}" -a "$pkt" "${email[$ta]}" 
        echo "$humor" | mutt -s "${SUBJECT}: ${zip%.zip}" -a "$pkt" -- "${email[$ta]}" 
        rm -f "$pkt"
    fi
done
