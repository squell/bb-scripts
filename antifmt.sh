#! /bin/bash

# repareer alle creatieve dingen die mensen opsturen
# - unzipped alle zips en rars (zonder dirs)
# - convert pdfs naar text met pdftotext
# - convert doc/rtf naar text met catdoc
# - convert docx/odt naar text met hacks
# - corrigeert line-endings {CR/LF, CR} -> LF
# - print een lijstje van tekstverwerkergebruikers

# nodig: catdoc geinstalleerd, ergens

source "${0%/*}"/config.cfg

declare -A unpack
de.zip() { unzip -a -n -j -d "${1%/*}" "$1"; }
de.rar() { unrar e -o- "$1" "${1%/*}"; }
de.7z()  { 7zr e -y -o"${1%/*}" "$1"; }
unpack[application/zip]=de.zip
unpack[application/x-7z-compressed]=de.7z
unpack[application/x-rar]=de.rar

# unzip & unrar
echo UnZIP\(`ls ${STUDDIRS}/*.zip 2> /dev/null | wc -l`\)/UnRAR\(`ls ${STUDDIRS}/*.rar 2> /dev/null | wc -l`\)/Un7Z\(`ls ${STUDDIRS}/*.7z 2> /dev/null | wc -l`\)/UnTAR\(`ls ${STUDDIRS}/*.tar* ${STUDDIRS}/*.tgz 2> /dev/null | wc -l`\) nested files
for zip in ${STUDDIRS}/*.zip ${STUDDIRS}/*.rar ${STUDDIRS}/*.7z; do
	if [ ! -e "$zip" ]; then continue; fi
	#7z e -y -o"${zip%/*}" "$zip" > "${zip}.contents"
	decrunch="${unpack["`file --brief --mime-type "$zip"`"]}"
	if [ "${zip##*.}" != "${decrunch##*.}" ]; then
		echo "$zip" is not a "${zip##*.}" file"${decrunch:+, detected ${decrunch##*.}}"
	fi
	[ "$decrunch" ] && $decrunch "${zip}" > "${zip}".contents
done
for gz in ${STUDDIRS}/*.gz ${STUDDIRS}/*.tgz; do [ -e "$gz" ] && gunzip -qf "$gz"; done
for bz in ${STUDDIRS}/*.bz2; do [ -e "$bz" ] && bunzip2 -qf "$bz"; done
for xz in ${STUDDIRS}/*.xz; do [ -e "$xz" ] && unxz -qf "$xz"; done
for tar in ${STUDDIRS}/*.tar; do
	[ "$tar" != "${STUDDIRS}/*.tar" ] && tar xCfv "${tar%/*}" "${tar}" --xform 's!.*/!!' > "${tar}.contents"
done

# correct msdos/mac line endings
#echo Converting Mac/MSDOS line-endings
#perl -pi -e 's/\r\n?/\n/g' ${STUDDIRS}/*.txt ${STUDDIRS}/*.[di]cl s/*.[Cc]*

# unpdfize stuff
echo Extracting text from PDF files \(`ls ${STUDDIRS}/*.pdf 2> /dev/null | wc -l`\)
for file in ${STUDDIRS}/*.pdf; do
	[ "$file" != "${STUDDIRS}/*.pdf" ] && pdftotext -layout "$file"
done

# complain about word
echo Bashing text out of Word files \(`ls ${STUDDIRS}/*.doc ${STUDDIRS}/*.rtf ${STUDDIRS}/*.docx ${STUDDIRS}/*.odt 2> /dev/null | wc -l`\)
for doc in doc rtf; do
    for file in ${STUDDIRS}/*.$doc; do
	[ "$file" != "${STUDDIRS}/*.$doc" ] && $CATDOC "${file}" > "${file%%.$doc}".txt
    done
done
for file in ${STUDDIRS}/*.docx; do
	[ "$file" != "${STUDDIRS}/*.docx" ] && unzip -p "$file" word/document.xml | sed 's|<w:br/>|\n&|g;s|</w:p>|\n&|g;s|<[^>]*>||g' > "${file%%.docx}".txt
done
for file in ${STUDDIRS}/*.odt; do
	[ "$file" != "${STUDDIRS}/*.odt" ] && unzip -p "$file" content.xml | sed 's|<text:tab/>|\t|g;s|<text:p|\n&|g;s|<[^>]*>||g' > "${file%%.odt}".txt
done


# kill all binaries
echo Killing superfluous files
rm -f ${STUDDIRS}/*.o ${STUDDIRS}/*.exe ${STUDDIRS}/*.prj ${STUDDIRS}/*.abc
rm -f ${STUDDIRS}/*.zip ${STUDDIRS}/*.rar ${STUDDIRS}/*.7z ${STUDDIRS}/*.tar

exit
# generate to-kill list
echo ""
echo This weeks offenders list:
for stupid in `ls ${STUDDIRS}/*.pdf ${STUDDIRS}/*.doc* ${STUDDIRS}/*.odt ${STUDDIRS}/*.rtf 2> /dev/null | sed 's:\([sez][0-9]*\)/.*:\1/\1.txt:g' | uniq`; do
	if [ -e "$stupid" ]; then
		head -q -n1 "$stupid" | sed 's/^Name //'
	else
		echo "Unknown? (${stupid%%/*})"
	fi
	#echo "LEVER GEEN .DOC of .PDF IN!" >> "$stupid"
done
