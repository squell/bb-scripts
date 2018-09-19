#! /bin/bash

# repair all the creative stuff students submit
# - unzip all compressed files/dirs (w/o directory structure)
# - convert pdfs to text using pdftotext
# - convert doc/rtf/docx/odt to text using libreoffice
# - correct line-endings {CR/LF, CR} -> LF
# - print a list of people who think Word is an IDE
shopt -s nullglob

if [ -z "$*" ]; then
	echo "Usage: antifmt.sh DIR1 DIR2 ..." >& 2
	exit 1
fi

for cmd in unzip unrar 7zr bunzip2 unxz pdftotext soffice; do
	if ! command -v $cmd >/dev/null 2>&1; then
		echo "Who am I? Why am I here? Am I on lilo? $cmd is missing!" >& 2
		exit 1
	fi
done

shopt -s nullglob

typeset -A unpack
de.zip() { unzip -a -n -j -d "${1%/*}" "$1"; }
de.rar() { unrar e -o- "$1" "${1%/*}"; }
de.7z()  { 7zr e -y -o"${1%/*}" "$1"; }
unpack[application/zip]=de.zip
unpack[application/x-7z-compressed]=de.7z
unpack[application/x-rar]=de.rar

typeset -A stat

report() {
	for key in "${!stat[@]}"; do
	    echo -n "$key(${stat[$key]}) "
	done
	echo -n $'\r'
}

# DEVELOPER NOTE:
# any argument that is not a directory is currently ignored
for studdir in "$@"; do
	# unzip & unrar
	for file in "$studdir"/*.zip "$studdir"/*.rar "$studdir"/*.7z; do
		#7z e -y -o"${zip%/*}" "$zip" > "${zip}.contents"
		decrunch="${unpack["`file --brief --mime-type "$file"`"]}"
		if [ "${file##*.}" != "${decrunch##*.}" ]; then
			echo "$file" is not a "${file##*.}" file"${decrunch:+, detected ${decrunch##*.}}"
		fi
		if [ "$decrunch" ]; then
		    let "stat[${decrunch##*.}]++"
		    $decrunch "${file}" > "${file}".contents
		else
		    let "stat[junk]++"
		    mv "$file" "${file}.junk"
		fi
	done
	for file in "$studdir"/*.gz "$studdir"/*.tgz; do gunzip -qf "$file"; done
	for file in "$studdir"/*.bz2; do bunzip2 -qf "$file"; done
	for file in "$studdir"/*.xz; do unxz -qf "$file"; done
	for file in "$studdir"/*.tar; do
		let "stat[tar]++"
		tar --force-local -xv -C "${file%/*}" -f "${file}" --xform 's!.*/!!' > "${file}.contents"
	done

	# correct msdos/mac line endings
	#echo Converting Mac/MSDOS line-endings
	#perl -pi -e 's/\r\n?/\n/g' "$studdir"/*.txt "$studdir"/*.[di]cl "$studdir"/*.[Cc]*

	# unpdfize stuff
	for file in "$studdir"/*.pdf; do
		let "stat[pdf]++"
		pdftotext -layout "$file" "$file.txt"
	done

	# complain about word
	for type in docx odt doc rtf; do
	    for file in "$studdir"/*.$doc; do
			let "stat[type]++"
			soffice --headless --cat "$file" > "$file.txt"
	    done
	done

	# kill all binaries
	rm -f "$studdir"/{*.o,*.obj,*.exe,*.prj,*.prp,*.abc}
	rm -f "$studdir"/{*.class,*.jar}
	rm -f "$studdir"/{*.zip,*.rar,*.7z,*.tar}

	report
done

# make sure append a newline
[[ ${#stat[@]} == 0 ]] || echo
