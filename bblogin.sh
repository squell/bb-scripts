#! /bin/sh

# (c) 2007 Marc Schoolderman
# Met veel dank aan Ruben Nijveld en Marlon Baeten voor hun
# reverse-engineering informatie van BlackBoard;

BBUSER="$1"

BBLOGIN="https://blackboard.ru.nl/webapps/login/"
BBGETTOKEN="https://blackboard.ru.nl/webapps/login/?action=relogin"
BBPORTAL="http://blackboard.ru.nl/webapps/portal/frameset.jsp"

MD5=md5sum
WGET="wget --quiet --no-check-certificate --load-cookies bb.cookie --save-cookies bb.cookie --keep-session-cookies"

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

	ONE_TIME_TOKEN=`$WGET -O - $BBGETTOKEN | sed -n 's/^.*<INPUT VALUE="\([0-9A-F]\+\)".*one_time_token.*>.*$/\1/p'`

	$WGET --post-data "action=login&one_time_token=$ONE_TIME_TOKEN&encoded_pw=`cr $pass`&encoded_pw_unicode=`cr_uni $pass`&password=&user_id=$BBUSER" $BBLOGIN
	pass=""

else
	echo Thank you. BlackBoard is being circumvented for your pleasure.
	$WGET $BBPORTAL
fi

if [ -e "frameset.jsp" ]; then
	echo Success! Muhaha.
	rm -f frameset.jsp
else
	echo Failed.
	rm -f nocookies.html index.html
	rm -f bb.cookie
	exit
fi

