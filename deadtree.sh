#! /bin/bash

# formatteer alle uitwerkingen als een lopende codelisting met headings 
# op stdout, geschikt voor lpr -Plp5
# (hiervoor is figlet nodig in $HOME/figlet)

FILESPEC="*.[CcTt]*"             # c/c++
FILESPEC="*.[tid][xc][tl]"       # clean

if [ "`uname`" == Linux ]; then
    FIGLET="$HOME/figlet/figlet -d $HOME/figlet/fonts"
else
    FIGLET="$HOME/figlet/figlet.sparc -d $HOME/figlet/fonts"
fi

for dir in s*; do
	if [ -e "$dir/$dir.txt" ]; then
		# banner `sed -n '1s/^Name \(.*\)(.*$/\1/p' "$dir/$dir.txt"`
		sed -n '1s/^Name \(.*\)(.*$/\1/p' "$dir/$dir.txt" | $FIGLET 
	else
		echo $dir | $FIGLET -fbanner
	fi
	pr -f -n -l1000 "$dir"/$FILESPEC | tr -d '\f' 
	# echo $'\f'
	echo "" | pr -l48 | sed "s/.*//"
done

