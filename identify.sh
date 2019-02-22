#! /bin/sh

# this script adds email addresses and student ids to folder names extracted
# from Brightspace, given a CSV file obtained via 'Enter Grades'

if [ -z "$1" ]; then
        echo "Usage: identify.sh spreadsheet.csv [dir1] [dir2] ... [dirN]" 1>&2
        exit 1
fi

CSV="$1"; shift

if [ ! -f "$CSV" ]; then
        echo "Usage: identify.sh spreadsheet.csv [dir1] [dir2] ... [dirN]" 1>&2
	exit 2
fi

# this is the old functionality of 'groepjes.sh': scrapes files for student ids
collect() {
        find "$1"/* -type f -not -name "*.WARNING" -print0 | xargs --null grep -oihI '\<[usefz]\?[0-9]\{6,7\}\>' | sed 's/\<[0-9]/#s&/' | tr USEFZ usefz
}

# note: column 5 is assumed to be 'OSIRIS CUR groups'
GROUP_COLUMN=6
group="${GROUP_COLUMN:+`head -n1 "$CSV" | sed 's/<[^>]*>//g' | cut -d, -f"$GROUP_COLUMN"`}"
# sanity check: if this CSV field is quoted, it is not a group
group="${group##\"*}"
# sanity check: does this column look like an actual group, or like a grade?
[ "$group" != "${group%Grade}" ] || group=""

# find a student by name in the CSV file
findstud() {
	mawk -v student="$1" '$1~student || $3" "$2==student || $3"  "$2==student { print; exit }' FS=, OFS=, "$CSV"
}

for dir in "$@"; do
	name="${dir%/}"
	name="${name#* - }"
	name="${name% - *}"
	if [ "$group" ]; then
		groupid="$(findstud "$name" | cut -d, -f"$GROUP_COLUMN")"
		touch "$dir/#group:$(basename "$groupid")"
	fi
	{ echo "$name"; collect "$dir"; } | while read id; do
		if info="$(findstud "$id")"; then
			echo "${info#\#}" | cut -d, -f1,4
			if [ "$group" ]; then
				groupid2="$(echo "$info" | cut -d, -f"$GROUP_COLUMN")"
				if [ "$groupid" != "$groupid2" ]; then
					echo 1>&2 "$dir: conflicting groups, $groupid and $groupid2"
				fi
			fi
		else
			echo 1>&2 "could not find entry for student: $id"
		fi
	done | sort -u > "$dir/#address.txt"
	[ -s "$dir/#address.txt" ] || rm -f "$dir/address.txt"
done
