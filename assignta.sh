#! /bin/bash

# Make group_* files based on a grade column
# Group all students according to that column and assign TAs to each group

BBGRADES="https://blackboard.ru.nl/webapps/gradebook/do/instructor/downloadGradebook"
BBITEMVIEW="${BBGRADES}?dispatch=viewDownloadOptions&course_id=_${BBCOURSEID}_1"
BBBASE="https://blackboard.ru.nl"

"${0%/*}"/bblogin2.sh "$BBUSER" 1>&2 || exit 1

CURL="curl --silent --cookie bb.cookie"
TASKS=`$CURL "$BBITEMVIEW" | sed -rn '1,/name="item"/d;/select/q;y/ _/_ /;s/^[^ ]* ([0-9]+)[^>]*>([^<]*).*$/\2|\1/p' | grep -v Total`

echo "Pick a group column:"
select assignment in $TASKS; do
    echo Engaging BlackBoard. Would you like some coffee?
    break
done
assignment="${assignment##*|}"

groups="${BBGRADES}?course_id=_${BBCOURSEID}_1&dispatch=viewDownloadOptions"
$CURL "$groups" | sed -n '/"downloadGradebookForm"/,${/nonce/s/^.*name=.\([.[:alpha:]]\+\).*value=.\([0-9a-f-]\+\).*$/\1=\2/p}' | tr '\n' '&' > bb.postdata
echo "course_id=_${BBCOURSEID}_1&item=_${assignment}_1&delimiter=TAB&hidden=false&downloadTo=LOCAL&dispatch=setDownloadOptions&userIds=&itemIds=&noCustomView=false&downloadOption=BYCOLUMN&targetPath_CSFile=&targetPath_attachmentType=C&targetPath_fileId=&bottom_Submit=Submit&" >> bb.postdata

gradesdownload="$($CURL --data @bb.postdata $BBGRADES | grep downloadGradebookForm)"
url="${BBBASE}$(echo "$gradesdownload" | sed -rn 's/.*action=\"([^\"]*)\".*/\1/p')"
echo "$gradesdownload" | tr '<' '\n' | sed -rn '/input/s/.*name=['"'"'"](.*)['"'"'"] value=['"'"'"](.*)['"'"'"].*/\1=\2/p' | tr '\n' '&' > bb.postdata
echo 'downloadOption=BYCOLUMN' >> bb.postdata

list="$($CURL --data @bb.postdata "$url" | tr -d '"' | cut -f3,7 | tail -n +2 | sed -r 's/\s+/-/g')"

rm -f groups.tmp
echo "$list" | cut -d'-' -f2 | sort | uniq | while read group; do
	if [ -n "$group" ]; then
		echo -e "$group:\t" >> groups.tmp
	else
		echo -e "no_group:\t" >> groups.tmp
	fi
done
editor groups.tmp

while read line; do
	if [ -n "$(echo "$line" | cut -sf2)" ]; then
		group="$(echo "$line" | cut -d: -f1)"
		echo "$list" |
			grep "\\-${group/no_group/}\$" |
			cut -d- -f1 > "group_$(echo "$line" | cut -f2)"
	fi
done < groups.tmp
rm groups.tmp

rm -f bb.postdata
