#! /bin/bash

# Blackboard 9.1 login-en-fetch assignments script

# Met veel dank aan Ruben Nijveld en Marlon Baeten voor hun
# reverse-engineering informatie van BlackBoard;

source "${0%/*}"/config.cfg

"$MYDIR"/bblogin2.sh "$BBUSER" 1>&2 || exit 1

if [ "$1" == "users" ]; then
    echo 1>&2 Only showing list of studentnumbers and email addresses
    $WGET "${BBUSERS}&showAll=true" | sed 's/<img[^>]*>//g;/^[[:space:]]*$/d' | sed -n '/profileCardAvatarThumb/{N;s/.*\([suezf][0-9]\{6,7\}\).*/\1/p};/@/s/[[:space:]]*\([[:print:]]\+@[[:print:]]\+[.][[:print:]]\+\)<.td>.*/\1/p' | sed -n 'h;n;x;G;s/\n/\t/p'
    exit
fi

TASKS=`$WGET "$BBITEMVIEW" | sed -rn '1,/name="item"/d;/select/q;y/ _/_ /;s/^[^ ]* ([0-9]+)[^>]*>([^<]*).*$/\2|\1/p' | grep -v Total`

select assignment in $TASKS; do
    echo Engaging BlackBoard. Would you like some coffee?
    break
done

if [ -z "$assignment" ]; then
    echo No assignments found. Are we logged in correctly?
    rm -f bb.cookie
    exit
fi

ASSIGNMENT_URL="${BBDOWNLOAD}?outcome_definition_id=${assignment##*|}&showAll=true&course_id=_${BBCOURSEID}_1&startIndex=0"

echo Creating grades.csv
echo Username,\""$assignment"\" | tr '_' ' ' > grades.csv

if [ "$1" == "all" ]; then
    echo Fetching everything.
    $WGET "$ASSIGNMENT_URL" | sed -n '/<form/,${/nonce/s/^.*name=.\([.[:alpha:]]\+\).*value=.\([0-9a-f-]\+\).*$/\1=\2/p}; /hidden/s/^.*needs_grading\([_0-9]\+\).*value="[a-z]\+".*$/students_to_export=\1/p; /hidden/s/^.*outcome_definition_id.*value="\([^"]\+\)".*$/outcome_definition_id=\1/p' | tr '\n' '&' > bb.postdata
else
    echo Fetching ungraded assignments. broken
    $WGET "$ASSIGNMENT_URL" | sed -n '/<form/,${/nonce/s/^.*name=.\([.[:alpha:]]\+\).*value=.\([0-9a-f-]\+\).*$/\1=\2/p}; /hidden/s/^.*needs_grading\([_0-9]\+\).*value="true".*$/students_to_export=\1/p; /hidden/s/^.*outcome_definition_id.*value="\([^"]\+\)".*$/outcome_definition_id=\1/p' | tr '\n' '&' > bb.postdata
fi

if grep -q "students_to_export" bb.postdata; then
    echo -n "&course_id=_${BBCOURSEID}_1" >> bb.postdata
    echo -n "&cmd=submit" >> bb.postdata
    filename="${assignment%%|*}.zip"
    $WGET -O "$filename" --no-quiet -nc --progress=dot -nv "${BBBASE}$(
	    $WGET --post-file bb.postdata $BBDOWNLOAD | sed -n '/Download assignments now/s/^.*href="\([^"]\+\)".*$/\1/p'
    )"
    echo Saved to "$filename"
else
    echo Which exist not.
fi

rm -f bb.postdata
