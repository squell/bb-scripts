#! /bin/bash

# create a emulated s123456 directory + response file from a downloaded mail message
# use: mboxbb.sh dir1 dir2 dir3

set -e

MYDIR="${0%/*}"

for dir in "$@"; do
	"$MYDIR"/antifmt.sh "$dir"
	"$MYDIR"/groepjes.sh "$dir"
	header="$dir"/`basename "$dir".txt`
	studnr=$(sed -n '/^Name: .*(\([suezf][0-9]\{6,7\}\))/s//\1/p' "$header")
	if [ -z "$studnr" ]; then
		echo 1>&2 "could not determine studentnumber for message $dir"
	else
		echo "$dir => $studnr"
		mv "$header" "$dir"/"$studnr".txt
		mkdir "$studnr"
		# may overwrite files, and that is fine
		mv "$dir"/* "$studnr"
		rmdir "$dir"
	fi
done
