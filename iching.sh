#! /bin/bash

url="http://www.thateden.co.uk/dirk/pred.php?ching1=$(($RANDOM%8+1))&ching2=$(($RANDOM%8+1))"

curl -s $url | sed '0,/class="pred"/d;s!</p>!\n\n!g;s/<br>/\n/g;s/<[^>]*>//g'
