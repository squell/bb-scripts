#! /bin/sh

# this script adds email addresses and student ids to folder names extracted
# from Brightspace, given a CSV file obtained via 'Enter Grades'

if [ -z "$1" ]; then
        echo "Usage: addraddr.sh spreadsheet.csv [dir1] [dir2] ... [dirN]" 1>&2
        exit 1
fi

CSV="$1"; shift

if [ ! -f "$CSV" ]; then
        echo "Usage: addraddr.sh spreadsheet.csv [dir1] [dir2] ... [dirN]" 1>&2
	exit 2
fi

# this is the old functionality of 'groepjes.sh': scrapes files for student ids
collect() {
        find "$1"/* -type f -not -name "*.WARNING" -print0 | xargs --null grep -oihI '\<[usefz]\?[0-9]\{6,7\}\>' | sed 's/\<[0-9]/#s&/' | tr USEFZ usefz
}


# brightspace appears to pick "firstname[space]tussenvoegsel[space]surname]"
# sadly, since first names can have spaces as well, and sometimes the tussenvoegsel
# is still made a part of the surname sometimes
splitname() {
	lastname="${1#*  }"
	if [ "$lastname" = "$1" ]; then
		# name has a 'tussenvoegsel'
		firstname="${1%% [[:lower:]]*}"
		lastname="${name#$firstname }"
		tussen="${lastname%% [[:upper:]]*}"
		lastname="${lastname#$tussen }"
	else
		firstname="${1%  $lastname}"
		tussen=""
	fi
}

for dir in "$@"; do
	name="${dir#* - }"
	name="${name% - *}"
	splitname "$name"
	{ echo "${tussen:+$tussen }$lastname,$firstname"; collect "$dir"; } | while read id; do
		if info="`grep -F -m1 "$id" "$CSV"`"; then
			echo "${info#\#}" | cut -d, -f1,4
		else
			echo 1>&2 "could not find entry for student: $id"
		fi
	done | sort -u > "$dir/#address.txt"
	[ -s "$dir/#address.txt" ] || rm -f "$dir/address.txt"
done
