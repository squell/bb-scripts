#! /bin/sh

# pol maakt het geven van uitgebreide feedback aan meerdere
# mensen gemakkelijker

EDITOR=vi

VAR='^\$\([[:alnum:][:space:]]\+\)$'
TEMP=`mktemp`
grep -ho "$VAR" "$@" | sort -u > "$TEMP"
$EDITOR "$TEMP"
sed -i -e "$(sed "s:$VAR:"'\n/^\$\1$/c:;s/$/\\/;${p;s/.*/\n#/}' "$TEMP")" "$@"
rm -f "$TEMP"
