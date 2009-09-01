#! /bin/bash

# Blackboard 7.3 login-en-fetch assignments script

# Met veel dank aan Ruben Nijveld en Marlon Baeten voor hun
# reverse-engineering informatie van BlackBoard;

MLW0708=22533
FP0809=27790

BBUSER=s0620866
BBCOURSEID=$MLW0708
BBCOURSEID=$FP0809

BBLOGIN="https://blackboard.ru.nl/webapps/login/"
BBGETTOKEN="https://blackboard.ru.nl/webapps/login/?action=relogin"
BBPORTAL="http://blackboard.ru.nl/webapps/portal/frameset.jsp"
BBGRADEBOOK="http://blackboard.ru.nl/webapps/gradebook/do/instructor/viewSpreadsheet?course_id=_${BBCOURSEID}_1"
BBDOWNLOAD="http://blackboard.ru.nl/webapps/blackboard/assignments/instructor/proc_download_assignment.jsp?course_id=_${BBCOURSEID}_1"
BBITEMVIEW="http://blackboard.ru.nl/webapps/gradebook/do/instructor/viewGradesByItem?course_id=_${BBCOURSEID}_1"

BBBASE="http://blackboard.ru.nl"

if [ `uname` = "Linux" ]; then
	MD5=md5sum
	WGET='wget --no-check-certificate --load-cookies bb.cookie --save-cookies bb.cookie --keep-session-cookies -U Mozilla/5.0'
else
	MD5=md5
	echo "Sorry, dit werkt (nog) niet onder solost."
	exit
fi

md5() {
    echo -n "$1" | $MD5 | cut -d' ' -f 1 | tr [:lower:] [:upper:]
}

md5_uni() {
    echo -n "$1" | sed 's/./&\n/g' | tr '\n' '\000' | $MD5 | cut -d' ' -f 1 | tr [:lower:] [:upper:]
}

cr() {
    md5 "$(md5 "$1")$ONE_TIME_TOKEN"
}

cr_uni() {
    md5_uni "$(md5_uni "$1")$ONE_TIME_TOKEN"
}

if [ ! -e bb.cookie ]; then
	read -p "Password: " -s pass
	echo
	echo Thank you. BlackBoard is being circumvented for your pleasure.

	ONE_TIME_TOKEN=`$WGET -q -O - $BBGETTOKEN | sed -n 's/^.*<INPUT VALUE="\([0-9A-F]\+\)".*one_time_token.*>.*$/\1/p'`

	$WGET -q --post-data "action=login&one_time_token=$ONE_TIME_TOKEN&encoded_pw=`cr $pass`&encoded_pw_unicode=`cr_uni $pass`&password=&user_id=$BBUSER" $BBLOGIN
	pass=""

else
	echo Thank you. BlackBoard is being circumvented for your pleasure.
	$WGET -q $BBPORTAL
fi

if [ -e "frameset.jsp" ]; then
	echo Success! Muhaha.
	rm -f frameset.jsp*
else
	echo Failed.
	rm -f nocookies.html* index.html*
	rm -f bb.cookie
	exit
fi

select assignment in $(
	$WGET -q -O - $BBITEMVIEW | sed -n '/outcomeDefinitionId/s!^.*outcomeDefinitionId=_\([0-9]\+\)_1">\(.*\)</a>.*$!\2 #\1%!p' | tr ' %' '_ '
); do
	assignment=${assignment##*#}
	echo Engaging BlackBoard. Would you like some coffee?
	break
done

if [ -z "$assignment" ]; then
	echo No assignments found. Are we logged in correctly?
	rm -f bb.cookie
	exit
fi

ASSIGNMENT_URL="http://blackboard.ru.nl/webapps/blackboard/assignments/instructor/download_assignment.jsp?outcome_definition_id=_${assignment}_1&course_id=_${BBCOURSEID}_1"

$WGET -q -O - $ASSIGNMENT_URL | sed -n '/checkbox/s/^.*students_to_export.*value="\([^"]\+\)".*$/students_to_export=\1/p; /hidden/s/^.*outcome_definition_id.*value="\([^"]\+\)".*$/outcome_definition_id=\1/p' | tr '\n' '&' > bb.postdata

if [ "$1" == "all" ]; then
    echo Fetching everything.
    $WGET -q -O - $ASSIGNMENT_URL | sed -n '/checkbox/s/^.*students_to_export.*value="\([^"]\+\)".*$/students_to_export=\1/p; /hidden/s/^.*outcome_definition_id.*value="\([^"]\+\)".*$/outcome_definition_id=\1/p' | tr '\n' '&' > bb.postdata
else
    echo Fetching ungraded assignments.
    $WGET -q -O - $ASSIGNMENT_URL | sed -n '/hidden/s/^.*needs_grading\([_0-9]\+\).*value="true".*$/students_to_export=\1/p; /hidden/s/^.*outcome_definition_id.*value="\([^"]\+\)".*$/outcome_definition_id=\1/p' | tr '\n' '&' > bb.postdata
fi

if grep -q "students_to_export" bb.postdata; then
    $WGET -nc --progress=dot -nv "${BBBASE}$(
	    $WGET -q --post-file bb.postdata -O - $BBDOWNLOAD | sed -n '/Download assignments now/s/^.*href="\([^"]\+\)".*$/\1/p'
    )"
else
    echo Which exist not.
fi

rm -f bb.postdata

