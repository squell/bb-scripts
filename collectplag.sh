#!/bin/sh

# Maakt een mapje met mogelijke plagiaatgevallen om aan de docent te versturen.
# Gebruik: ./collectplag.sh s123 s456 s789

# Het resultaat is een map plag-s123-s456-s789 en diezelfde map ge-targz'ed.
# De output bevat een template voor een email aan de docent, met daarin de
# namen / nummers van de studenten en of ze al een cijfer in Blackboard hebben.

# Dit script neemt aan dat je de volgende setup hebt gedaan:
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
