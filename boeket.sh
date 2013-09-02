#! /bin/bash

URL=http://www.agfl.cs.ru.nl/cgi-bin/boeket/boeket.cgi

wget -q -O - $URL | sed -n '/HR/,/\/p/s/^ *\([^<>]*\)$/\1/p' | sed 's/ *\([[:punct:]]\)/\1/g' | fmt

