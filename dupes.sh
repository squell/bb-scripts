#! /bin/bash

MYDIR="${0%/*}"
DIFF="diff --ignore-all-space --minimal --side-by-side --width=160 --left-column"

author() {
    echo "${1%%/*}"
}

cvt() {
    #iconv -f windows-1252 | col
    tr -c '[:print:][:cntrl:]' '?' | col
}

remove_comments() {
    tr -cd '[:print:][:cntrl:]' | sed -rn ':0 N;${s:/\*([^*]|\*[^/])*\*/: :g;p};b0' | sed 's://.*$::'
}

collapse_string_constants() {
    #sed 's/""//g;s/"[^"]\+"/"/g'
    #sed 's/"[^"]*"//g'
    sed "s/'.'/'/g"';s/"\(\\.\|[^"]\)*"/"/g'
}

fingerprint() {
    echo -n 0
    cat "$1" | remove_comments | collapse_string_constants | sed 's/[><=]=/<>/g;s/</>/g;s/\(package\|import\) [A-Za-z0-9_.]\+;//g;s/return/!!/g;s/public/$/g;s/class/#/g;s/private/$/g;s/final//g;s/\(if\|switch\)/?/g;s/\(for\|while\)/?/g;s/\<[A-Z][A-Za-z0-9_]*\>/I/g;s/\<[a-z][A-Za-z0-9_]\+\>/i/g;s/[0-9]\+/i/g' | tr -cd '5!?iI#<>\n:~*$\\[]{}()"' | tr ' \t\n\\"' 'abcde' | sed -r 's/c+/c/g;s/c$//'
}

if [ -z "$*" ]; then
        echo usage: dupes.sh dir >& 2
        exit
fi

if [ ! -d "$1" ]; then
        fingerprint "$1"
        exit
fi

declare -A fingerprints

# enable recursive globbing **/*.java
shopt -s globstar


echo Dupechecking
for arg in "$@"; do
    for file in "$arg"/**/*.java; do
        test -e "$file" || break
        test -e "${file}.SUSPECT" && continue
        code=`fingerprint "$file"`
        if [ "${#code}" -ge 42 ]; then
            found="${fingerprints[$code]}"
            if [ -z "$found" ]; then
                fingerprints[$code]="$file"
            elif [ "${found%%/*}" = "${file%%/*}" ]; then
                # not a duplicate, because it is from the same hand-in
                true
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

