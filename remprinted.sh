#! /bin/sh

# remove all s* directories which do not have unprinted pdf's

STUDDIRS="[sez][0-9]*"

for stud in $STUDDIRS; do
    	for pdf in "$stud"/*.pdf; do
	    	if [ -e "$pdf" ] && [ ! -e "$pdf.printed" ]; then
		    	continue 2
		fi 
	done
	# haven't found any unprinted pdf's. to the unix gallows.
	rm -rd "$stud"
done
