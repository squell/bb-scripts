#!/bin/sh
# Becijfer een willekeurig, nog niet becijferd, groepje
# de -pdf vlag opent pdfs ook in een grafische editor
EDITOR="vi -p"
PDFVIEW="evince"
PAT="Needs Grading"
GLB='./[usef][0-9][0-9][0-9]*/[usef][0-9][0-9][0-9]*.txt'
DIR="$(grep -Fl "$PAT" $GLB | shuf | head -1)"
if [ -n "$DIR" ]; then
	cd "$(dirname "$DIR")"
	if [ "$1" = "-pdf" ]; then
		PID=0
		count=$(ls -1 | grep '\.pdf$' | wc -l)
		if [ $count != 0 ]; then
			$PDFVIEW *.pdf & PID=$!
		fi
	fi
	$EDITOR *
	if [ "$1" = "-pdf" ] && [ $PID != 0 ]; then
		kill $PID 2>/dev/null
	fi
	cd ..
fi
echo "$DIR klaar. Nog $(grep -Fl "$PAT" $GLB | wc -l) te gaan..."
