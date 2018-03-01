#!/bin/sh

# Makes a directory with possible plagiarism cases to send to the teacher.
# Usage: ./collectplag.sh s123 s456 ...

# The result is a directory plag-s123-s456-... and a tarball of that directory.
# The output shows a template for an email to the teacher, with a list of the
# students concerned and whether they have a grade in blackboard or not.

# The script assumes the following setup:
# ./getsch.sh users > userlist
# ./getsch.sh all
# ./bbfix.sh XXX.zip
# ./antifmt.sh
# ./groepjes.sh [ufsez][0-9]*

dir="plag"
for arg in $@; do
	dir="$dir-$arg"
done

if [ -e "$dir" ]; then
	echo "$dir already exists."
	exit 127
fi
mkdir "$dir"

for arg in $@; do
	cp -R "$arg" "$dir/$arg"
done

tar czvf "$dir.tar.gz" "$dir"

echo "--------------------"
echo -n "Hoi,\n\nDeze groepjes hebben soortgelijke uitwerkingen ingeleverd:\n\n"
for arg in $@; do
	HASGRADE=""
	grep 'Needs Grading' "$arg/$arg.txt" >/dev/null || HASGRADE=" (heeft al een cijfer)"
	grep '^Name:' "$arg/$arg.txt" | sed "s/Name: / - /;s/$/$HASGRADE/"
	echo
done
echo -n "\nDe uitwerkingen staan in de bijlage.\nIk zal wachten met becijferen totdat het is bekeken.\n\nGroet,\n"
echo "$USER" | sed 's/.*/\u&/'
