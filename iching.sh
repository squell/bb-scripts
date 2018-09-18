#! /bin/bash

for cmd in curl
do
	if ! command -v $cmd >/dev/null 2>&1
	then
		echo "Who am I? Why am I here? Am I on lilo? $cmd is missing!" >& 2
		exit 1
	fi
done

url="http://www.thateden.co.uk/dirk/pred.php?ching1=$(($RANDOM%8+1))&ching2=$(($RANDOM%8+1))"

curl -s $url | sed '0,/class="pred"/d;s!</p>!\n\n!g;s/<br>/\n/g;s/<[^>]*>//g'
