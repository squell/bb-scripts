#! /bin/bash

# Blackboard 9.1 upload-grades-csv script
# - experimental!
# - since we upload multipart data, this script uses curl, not wget
# - might break if curl and wget cookiejars become incompatible

source "${0%/*}"/config.cfg

if [ -z "$1" ]; then
    echo usage: upload.sh grades.csv
    exit 1
fi

# code starts here

HEAD=`head -n1 "$1" | cut -d, -f2 | tr -d '"'`
ITEMNAME="${HEAD%|*}"
ITEMID="${HEAD#*|}"

export BBCOURSEID
"$USERLIST"/bblogin2.sh "$BBUSER" 1>&2 || exit 1

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
$CURL --data "$NONCE" --data "course_id=_${BBCOURSEID}_1" --data "actionType=import" --data "bottom_Submit=Submit" --data "itemId=_${ITEMID}_1" --data "itemName=${ITEMNAME}" --data "items=0" --data "item_positions=,0" "$BBUPLOAD" | grep -o "Total Grades Uploaded:[[:space:]]*[[:digit:]]*" || echo "Could not fill in the grades in the Grade Center. If you're entering characters, this probably means the column's type is wrong. Try changing 'Primary Display' to 'Text'."

# i'm not sure why item_positions should be ,0 ...
