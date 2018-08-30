#! /bin/sh

# convert a flat directory into a jar file
# - when run without arguments, convert the current directory
# - when run with argument, convert every mentioned directory
TMPDIR=/tmp/JARIFY

jarify() (
	WD="${1:+$1/}"

	# check the directory contains java files, if not, quit
	for file in "$WD"*java; do
	    if [ "$file" = "$WD*java" ]; then
		exit
	    fi
	    break
	done

	mkdir -p "$TMPDIR"

	javac -d "$TMPDIR" -Xlint -Xlint:-unchecked "$WD"*.java 

	MAINJAVA=$(egrep -l '((public|static)[[:space:]]+){2}void[[:space:]]+main' "$WD"*.java)
	MAINJAVA="${MAINJAVA##*/}"
	MAINCLASS=$(find "$TMPDIR" -name "${MAINJAVA%.java}.*" -printf "%P\n")

	CWD="$PWD"
	cd "$TMPDIR"
	jar cfe runme.jar "${MAINCLASS%.class}" *
	chmod +x runme.jar
	cd "$CWD"
	cp -f "$TMPDIR/runme.jar" "${WD:-.}"

	rm -rf "$TMPDIR"
)

while jarify "$1"; [ "$2" ]; do
	shift
done
