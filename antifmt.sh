#! /bin/bash

# repareer alle krankzinnige dingen die mensen opsturen
# - unzipped alle zips en rars (zonder dirs)
# - convert pdfs naar text
# - convert doc/rtf naar text
# - corrigeert line-endings {CR/LF, CR} -> LF
# - print een lijstje van studenten die deze rotzooi opsturen

# nodig: catdoc geinstalleerd, ergens

CATDOC="$HOME/catdoc/bin/catdoc"

# unzip & unrar
echo UnRAR \(`ls s*/*.rar 2> /dev/null | wc -w`\)/UnZIP \(`ls s*/*.zip 2> /dev/null | wc -w`\) nested files
for zip in s*/*.zip; do
	[ "$zip" != "s*/*.zip" ] && unzip -n -j -d "${zip%/*}" "$zip"
done
for rar in s*/*.rar; do
	[ "$rar" != "s*/*.rar" ] && unrar e -o- "$rar" "${rar%/*}"
done

# correct msdos/mac line endings
#echo Converting Mac/MSDOS line-endings
#perl -pi -e 's/\r\n?/\n/g' s*/*.txt s*/*.[di]cl s/*.[Cc]*

# unpdfize stuff
echo Extracting text from PDF files \(`ls s*/*.pdf 2> /dev/null | wc -w`\)
pdftotext -layout s*/*.pdf

# complain about word
echo Bashing text out of Word files \(`ls s*/*.doc | wc -w`\)
for file in s*/*.[dr][ot][cf]; do
	[ "$file" != "s*/*.doc" ] && $CATDOC "${file}" > "${file%%.doc}".txt
done

# generate to-kill list
echo ""
echo This weeks offenders list:
for stupid in `ls s*/*.zip s*/*.rar s*/*.pdf s*/*.doc 2> /dev/null | sed 's:\(s[0-9]*\)/.*:\1/\1.txt:g'`; do
	if [ -e "$stupid" ]; then
		head -q -n1 "$stupid" | sed 's/^Name //'
	else
		echo "Unknown? (${stupid%%/*})"
	fi
done

