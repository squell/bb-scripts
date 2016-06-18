#! /bin/sh

# pol maakt het geven van uitgebreide feedback aan meerdere
# mensen gemakkelijker (maar kijk niet hoe)

EDITOR=vi

VAR='^\(\$[[:alnum:][:space:]]\+\)'
TEMP=`mktemp`
sed "/${VAR}:$/",'/^\$$/!d;/^\$/{s/://;/\$$/d}' "$@" >> "$TEMP"
grep -ho "${VAR}$" "$@" | grep -Fvxf "$TEMP" - | sort -u >> "$TEMP"
$EDITOR "$TEMP"
sed -i -e "/${VAR}:$/d;/^\$$/s///;$(sed "s:${VAR}$:"'\n/^\1$/c:;s/\\/\\\\/g;s/$/\\/;$s/$/\n\n#/' "$TEMP")" "$@"
rm -f "$TEMP"
