#! /bin/sh

URL=http://www.agfl.cs.ru.nl/cgi-bin/boeket/boeket.cgi

curl -s $URL | sed -n '/HR/,/\/p/s/^ *\([^<>]*\)$/\1/p' | sed 's/ *\([[:punct:]]\)/\1/g' | fmt

