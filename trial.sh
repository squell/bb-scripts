#! /bin/sh

# test uitwerkingen; voer Gast-tests uit

UITWERKINGEN=$HOME/FP2013/Uitwerkingen
CLEANDIR="$HOME/Clean/clean64"
LIB="${CLEANDIR}/lib"
CLM="${CLEANDIR}/bin/clm -h 64m -s 8m"

if [ -z "$1" ]; then
	echo "usage: trial.sh dir"
	exit
fi

export CLEANPATH="${LIB}/StdEnv:${LIB}/StdLib:${LIB}/Gast:${LIB}/Generics:${LIB}/MersenneTwister"

gast_test()
{
	set -m
	suffix="Test"
	timeout=3
	log="${f%/*}/gast_results.txt"
	suite="${f##*/}"
	suite="${suite%.icl}$suffix"
	#exe="${dir}"/a.out"$suite"
	exe="${dir}"/"$suite"

	if [ "$suffix" ] && [ -e "$UITWERKINGEN/${suite}.icl" ] && [ ! -e "${dir}/${suite}.icl" ]; then
	    rm -rf "$UITWERKINGEN/Clean System Files"
	    echo Gast-test "${f%.icl}"
	    echo "[$suite]" >> "$log" 
	    if $CLM -ms -nw -ci -b -nt -I "$dir" -I "$UITWERKINGEN" "$suite" -o "$exe" 2>> "$log"; then
		    #($exe 2>> "$log" || echo "*** aborted") >> "$log" & pid=$!
		    (($exe 2>> "$log" || echo "*** aborted") | sed 's/^.*\r//') >> "$log" & pid=$!
		    sleep $timeout && kill -9 "-$pid" & w=$!
		    if wait $pid; then
			kill -9 -$w 2> /dev/null > /dev/null
		    else
			echo "*** killed (DUURT LANG)" >> "$log"
		    fi
	    else
		    echo "*** not performed (compile error)" >> "$log"
	    fi
	    rm -f "$exe"
	fi
	set +m
}

remcom() {
    tr -cd '[:print:][:cntrl:]' | sed -rn ':0 N;${s:/\*([^*]|\*[^/])*\*/: :g;p};b0' | sed 's://.*$::'
}

gen_dcl()
{
	remcom | sed -rn '/Start/d;s/^implementation/definition/p;/^[^:[:space:]].*::/p;/^::/s/(:?=.*)?$//p;/import/p;/instance/s/(where.*)?$//p'
}

for dir in "$@"; do
	rm -f "$dir/gast_results.txt"
	for f in "$dir"/*.icl; do
		[ -f "$f" ] || break
		#grep -q -e "^implementation" -e '^Start' "$f" || (echo ; echo "Start = undef // ADDED BY trial.sh" >> "$f")
		if $CLM -c -I "$dir" -I "$UITWERKINGEN" "${f%.icl}" 2> "$f".ERROR; then
			rm "$f".ERROR
			gast_test
		elif [ ! -e "${f%.icl}.dcl" ] && grep -q "^implementation" "$f"; then
			dcl="${f%.icl}.dcl"
			echo "// GENERATED FROM .icl FILE BY trial.sh" > "$dcl"
			echo "Using an induced .dcl" > "$f".ERROR
			gen_dcl < "$f" >> "$dcl"
			if $CLM -c -I "$dir" -I "$UITWERKINGEN" "${f%.icl}" 2>> "$f".ERROR; then
				echo Generated dcl for "${f%.icl}"
				rm "$f".ERROR
				gast_test
			else
				true #rm "$dcl"
			fi
		fi
	done
done

rm -rf "$UITWERKINGEN/Clean System Files"

