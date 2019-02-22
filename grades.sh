#! /bin/sh

if [ -z "$*" ]; then
	echo "Usage: grades.sh */file.txt" >& 2
	exit
fi

for file in "$@"; do
	TOID=`sed 's/,.*//' "$(dirname "$file")/#address.txt"`
	GRADE=`sed -n '/^Grade:[[:space:]]*/{s///p;q;}' "$file"`

	for id in $TOID; do
		if [ "$GRADE" ]; then
			echo "#$id,${GRADE},#"
			#TODO do we still need this blackboard-era workaround?
			#GRADE="${GRADE##0*}"
			#echo "#$id,${GRADE:-0.000001},#"
		fi
	done
done

