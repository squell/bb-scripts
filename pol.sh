#! /bin/sh

# pol allows providing the same feedback to multiple users
# (seriously, the code below has been field-tested and it works)

# usage: pol.sh <file1> <file2> ...
# this will find all macro definitions and applications, present
# you with an editor to make final adjustments/definitions, and
# then apply the appropropriate substitutions
#
# a macro is defined (inline) as:
# $rtfm:
# Have you tried reading the assignment before submitting?
# $
#
# and applied simply as (on a line by itself):
#
# $rtfm

VAR='^\(\$[[:alnum:][:space:]_]\+\)'
TEMP=`mktemp`
sed "/${VAR}:$/",'/^\$$/!d;/^\$/{s/://;/\$$/d}' "$@" >> "$TEMP"
grep -ho "${VAR}$" "$@" | grep -Fvxf "$TEMP" - | sort -u >> "$TEMP"
${EDITOR:-vi} "$TEMP"
sed -i -e "/${VAR}:$/d;/^\$$/s///;$(sed "s:${VAR}$:"'\n/^\1$/c:;s/\\/\\\\/g;s/$/\\/;$s/$/\n\n#/' "$TEMP")" "$@"
rm -f "$TEMP"
