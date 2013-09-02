#! /bin/bash

# repareer alle creatieve dingen die mensen opsturen
# - unzipped alle zips en rars (zonder dirs)
# - convert pdfs naar text met pdftotext
# - convert doc/rtf naar text met catdoc
# - convert docx/odt naar text met hacks
# - corrigeert line-endings {CR/LF, CR} -> LF
# - print een lijstje van tekstverwerkergebruikers

# nodig: catdoc geinstalleerd, ergens

CATDOC="$HOME/catdoc/bin/catdoc"

declare -A unpack
de.zip() { unzip -a -n -j -d "${1%/*}" "$1"; }
de.rar() { unrar e -o- "$1" "${1%/*}"; }
de.7z()  { 7zr e -y -o"${1%/*}" "$1"; }
unpack[application/zip]=de.zip
unpack[application/x-7z-compressed]=de.7z
unpack[application/x-rar]=de.rar

# unzip & unrar
echo UnZIP\(`ls s*/*.zip 2> /dev/null | wc -w`\)/UnRAR\(`ls s*/*.rar 2> /dev/null | wc -w`\)/Un7Z\(`ls s*/*.7z 2> /dev/null | wc -w`\)/UnTAR\(`ls s*/*.tar* s*/*.tgz 2> /dev/null | wc -w`\) nested files
for zip in s*/*.zip s*/*.rar s*/*.7z; do
	if [ ! -e "$zip" ]; then continue; fi
	#7z e -y -o"${zip%/*}" "$zip" > "${zip}.contents"
	decrunch="${unpack["`file --brief --mime-type "$zip"`"]}"
	if [ "${zip##*.}" != "${decrunch##*.}" ]; then
		echo "$zip" is not a "${zip##*.}" file"${decrunch:+, detected ${decrunch##*.}}"
	fi
	[ "$decrunch" ] && $decrunch "${zip}" > "${zip}".contents
done
for gz in s*/*.gz s*/*.tgz; do [ -e "$gz" ] && gunzip -qf "$gz"; done
for bz in s*/*.bz2; do [ -e "$bz" ] && bunzip2 -qf "$bz"; done
for xz in s*/*.xz; do [ -e "$xz" ] && unxz -qf "$xz"; done
for tar in s*/*.tar; do
	[ "$tar" != "s*/*.tar" ] && tar xCfv "${tar%/*}" "${tar}" --xform 's!.*/!!' > "${tar}.contents"
done

# correct msdos/mac line endings
#echo Converting Mac/MSDOS line-endings
#perl -pi -e 's/\r\n?/\n/g' s*/*.txt s*/*.[di]cl s/*.[Cc]*

# unpdfize stuff
echo Extracting text from PDF files \(`ls s*/*.pdf 2> /dev/null | wc -w`\)
for file in s*/*.pdf; do
	[ "$file" != "s*/*.pdf" ] && pdftotext -layout "$file"
done

# complain about word
echo Bashing text out of Word files \(`ls s*/*.doc s*/*.rtf s*/*.docx s*/*.odt 2> /dev/null | wc -w`\)
for doc in doc rtf; do
    for file in s*/*.$doc; do
	[ "$file" != "s*/*.$doc" ] && $CATDOC "${file}" > "${file%%.$doc}".txt
    done
done
for file in s*/*.docx; do
	[ "$file" != "s*/*.docx" ] && unzip -p "$file" word/document.xml | sed 's|<w:br/>|\n&|g;s|</w:p>|\n&|g;s|<[^>]*>||g' > "${file%%.docx}".txt
done
for file in s*/*.odt; do
	[ "$file" != "s*/*.odt" ] && unzip -p "$file" content.xml | sed 's|<text:tab/>|\t|g;s|<text:p|\n&|g;s|<[^>]*>||g' > "${file%%.odt}".txt
done


# kill all binaries
echo Killing superfluous files
rm -f s*/*.o s*/*.exe s*/*.prj s*/*.abc
rm -f s*/*.zip s*/*.rar s*/*.7z s*/*.tar

exit
# generate to-kill list
echo ""
echo This weeks offenders list:
for stupid in `ls s*/*.pdf s*/*.doc* s*/*.odt s*/*.rtf 2> /dev/null | sed 's:\(s[0-9]*\)/.*:\1/\1.txt:g' | uniq`; do
	if [ -e "$stupid" ]; then
		head -q -n1 "$stupid" | sed 's/^Name //'
	else
		echo "Unknown? (${stupid%%/*})"
	fi
	#echo "LEVER GEEN .DOC of .PDF IN!" >> "$stupid"
done

