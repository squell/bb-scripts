#! /bin/bash

# Blackboard 9.1 upload-grades-csv script
# - experimental!
# - since we upload multipart data, this script uses curl, not wget

BBCOURSEID=91125 # FP 2013
#BBCOURSEID=91131 # FP 2013 KI

# if this next variable is set, you will not be asked for your login
#BBUSER=...

if [ -z "$1" ]; then
    echo usage: upload.sh grades.csv
    exit 1
fi

# code starts here

HEAD=`head -n1 "$1" | cut -d, -f2 | tr -d '"'`
ITEMNAME="${HEAD%|*}"
ITEMID="${HEAD#*|}"

BBUPLOAD="https://blackboard.ru.nl/webapps/gradebook/do/instructor/uploadGradebook2?course_id=_${BBCOURSEID}_1"

CURL="curl --silent --cookie bb.cookie --cookie-jar bb.cookie"

"${0%/*}"/bblogin2.sh "$BBUSER" 1>&2 || exit 1

nonce() {
	sed -n '/<form/,${/nonce/s/^.*name=.\([.[:alpha:]]\+\).*value=.\([0-9a-f-]\+\).*$/\1=\2/p;q}' 
}

NONCE=`$CURL "$BBUPLOAD" | nonce`

review=`$CURL --form "$NONCE" --form "course_id=_${BBCOURSEID}_1" --form "actionType=processFile" --form "top_Submit=Submit" --form "delimiter=COMMA" --form "theFile_LocalFile0=@$1" --form "theFile_attachmentType=L" --form "theFile_linkTitle=grades.csv" --form "theFile_permissions0=A" --form "theFile_permissionOptionsIndex=-1" "$BBUPLOAD"`

echo "Please verify this information:"
echo "-----"
echo "$review" | sed '\:<table[^>]*>:,\:</table>:!d' | html2text
echo "-----"

select check in "This is expected" "WTF?"; do
    if [ "$check" != "This is expected" ]; then
	echo "Indeed?"
	exit
    fi
    break
done

NONCE=`echo "$review" | nonce`
$CURL --data "$NONCE" --data "course_id=_${BBCOURSEID}_1" --data "actionType=import" --data "bottom_Submit=Submit" --data "itemId=_${ITEMID}_1" --data "itemName=${ITEMNAME}" --data "items=0" --data "item_positions=,0" "$BBUPLOAD" | grep -o "Total Grades Uploaded:[[:space:]]*[[:digit:]]*" || echo "Woops!"

# i'm not sure why item_positions should be ,0 ...

