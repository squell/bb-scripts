#! /bin/bash

MYDIR="${0%/*}"
UITWERKINGEN="$MYDIR"/Vorigjaar
PRACTICUM="$MYDIR"/Practicum
DIFF="diff --ignore-all-space --minimal --side-by-side --width=160 --left-column"

cvt() {
    #iconv -f windows-1252 | col
    tr -c '[:print:][:cntrl:]' '?' | col
}


remcom() {
    tr -cd '[:print:][:cntrl:]' | sed -rn ':0 N;${s:/\*([^*]|\*[^/])*\*/: :g;p};b0' | sed 's://.*$::'
}

strk() {
    #sed 's/""//g;s/"[^"]\+"/"/g'
    #sed 's/"[^"]*"//g'
    tr \' \" | sed 's/"\(\\.\|[^"]\)*"//g'
}

filter() {
    echo -n 0
    #cat "$1" | unexpand -a | tr -cd ' \t\n=:' | tr ' \t\n' 'abc' | sed 's/a\+/a/g;s/c\+/c/g'
    #cat "$1" | remcom | sed 's://.*$::;s:[[:space:]]\+: :g' | tr -cd '\t\n=:|' | tr ' \t\n' 'abc' | sed 's/a\+/a/g;s/c\+/c/g'
    #cat "$1" | remcom | tr -cd '\n:=|,' | tr ' \t\n' 'abc' | sed 's/c\+/c/g;s/c$//'
    #cat "$1" | remcom | tr -cd '\n:=|[]' | tr ' \t\n' 'abc' | sed 's/c\+/c/g;s/c$//;s/^$/c/'
    #cat "$1" | remcom | tr -cd '\n:=|[]' | tr ' \t\n' 'abc' | sed 's/\(\>\|^\)=\(\<\|$\)//g;s/c\+/c/g;s/c$//;s/^$/c/'
    #cat "$1" | remcom | tr -cd '\n:=|' | tr ' \t\n' 'abc' | sed 's/\(\>\|^\)=\(\<\|$\)//g;s/c\+/c/g;s/c$//;s/^$/c/'
    #cat "$1" | remcom | tr -cd '\n:=|\\' | tr ' \t\n\\' 'abcd' | sed 's/\(\>\|^\)=\(\<\|$\)//g;s/c\+/c/g;s/c$//;s/^$/c/'
    #cat "$1" | remcom | strk | sed 's/==//g' | tr -cd '\n:=|\\"' | tr ' \t\n\\"' 'abc+$' | sed 's/\(\>\|^\)=\(\<\|$\)//g;s/c\+/c/g;s/c$//'
    #cat "$1" | remcom | strk | sed 's/==//g' | tr -cd '\n:=|\\[]{}"' | tr ' \t\n\\"' 'abc+$' | sed -r 's/(\>|^)=(\<|$)//g;s/\[]//g;s/c+/c/g;s/c$//'
    #cat "$1" | remcom | strk | sed 's/==//g' | tr -cd '\n:=|\\[]{}"' | tr ' \t\n\\"' 'abc+$' | sed -r 's/(\>|^)(=|::)(\<|$)//g;s/\[]//g;s/c+/c/g;s/c$//'
    #cat "$1" | remcom | strk | sed 's/[=<>]=//g' | tr -cd '\n:=|\\[]{}"' | tr ' \t\n\\"' 'abc+$' | sed -r 's/(\>|^)(=|::)(\<|$)//g;s/\[]//g;s/c+/c/g;s/c$//'
    cat "$1" | remcom | strk | sed 's/->/=/g;s/[=<>]=//g' | tr -cd '\n:=|\\[]{}"' | tr ' \t\n\\"' 'abc+$' | sed -r 's/(\>|^)(=|::)(\<|$)//g;s/\[]//g;s/c+/c/g;s/c$//'
}

if [ -z "$*" ]; then
	echo usage: plaggen.sh dir [defaulting to stream mode]
	exit
fi

if [ ! -d "$1" ]; then
	echo `filter "$1"`
	exit
fi

echo Fraud detection kit 
echo Generating signatures
declare -A sig

for orig in "$UITWERKINGEN"/*icl; do
	base="${orig##*/}"
	code=`filter "$UITWERKINGEN/$base"`
	if [ "${#code}" -ge 12 ]; then
	    sig[$code]="$base"
	else
	    echo Granting $orig
	fi
done

for tpl in "$PRACTICUM"/*.icl; do
	code=`filter "$tpl"`
	found="${sig[$code]}"
	if test "$found"; then
		unset sig[$code]
		echo Granting $found, by $tpl 
	fi
done

for arg in "$@"; do
	echo Inspecting $arg
	for file in "$arg"/*.icl; do
		test -e "$file" || break
		found="${sig[`filter "$file"`]}"
		if test "$found"; then
			echo 1>&2 "$file ?= $UITWERKINGEN/$found"
			echo "[$UITWERKINGEN/$found]" > "${file}.SUSPECT"
			$DIFF "$UITWERKINGEN/$found" "$file" | cvt >> "${file}.SUSPECT"
			echo "" >> "${file}.SUSPECT"
		fi
	done
done

