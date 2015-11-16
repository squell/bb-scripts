#! /bin/bash

MYDIR="${0%/*}"
PRACTICUM="$MYDIR"/Practicum
DIFF="diff --ignore-all-space --minimal --side-by-side --width=160 --left-column"
USERLIST="$MYDIR"/userlist

author() {
    grep "${1%%/*}" "$USERLIST" | cut -f2
}

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
    #cat "$1" | remcom | strk | sed 's/==//g;s/instance/"/g' | tr -cd '\n:=|\\[]{}"' | tr ' \t\n\\"' 'abc+$' | sed -r 's/(\>|^)=(\<|$)//g;s/\[]//g;s/c+/c/g;s/c$//'
    cat "$1" | remcom | strk | sed 's/->/=/g;s/[=<>]=//g;s/instance/"/g' | tr -cd '\n:=|\\[]{}"' | tr ' \t\n\\"' 'abc+$' | sed -r 's/(\>|^)(=|::)(\<|$)//g;s/\[]//g;s/c+/c/g;s/c$//'
}

if [ -z "$*" ]; then
	echo usage: dupes.sh dir
	exit
fi

if [ ! -d "$1" ]; then
	echo `filter "$1"`
	exit
fi

echo Unimportant signatures
declare -A prac
declare -A sig

for tpl in "$PRACTICUM"/*.icl; do
	prac[`filter "$tpl"`]="$tpl"
done

echo Dupechecking
for arg in "$@"; do
    for file in "$arg"/*.icl; do
	test -e "$file" || break
	test -e "${file}.SUSPECT" && continue
	code=`filter "$file"`
	if [ "${#code}" -ge 12 ] && [ -z "${prac[$code]}" ]; then
	    found="${sig[$code]}"
	    #if [ -z "$found" ]; then
	    if [ -z "$found" -a "${#code}" -ge 7 ]; then
		sig[$code]="$file"
	    else
		echo 1>&2 "$file ?= $found"
		echo "[$found | `author "$found"`] <==> [$file | `author "$file"`]" > "${file}.WARNING"
		$DIFF "$found" "$file" | cvt >> "${file}.WARNING"
		echo "" >> "${file}.WARNING"

		test -e "${found}.WARNING" && echo "===========================================" >> "${found}.WARNING"
		echo "[$file | `author "$file"`] <==> [$found | `author "$found"`]" >> "${found}.WARNING"
		$DIFF "$file" "$found" | cvt >> "${found}.WARNING"
		echo "" >> "${found}.WARNING"
	    fi
	fi
    done
done

