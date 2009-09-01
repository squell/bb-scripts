#! /bin/bash

# verdeel alle s* directories in de gegeven verhouding over phobos en deimos
# bijv. "hak.sh 1/2" om iets random 50/50 te verdelen
# voor bijv. 3 assistenten: eerst verdelen met 2/3 en daarna de grotere
# stapel nog een keer verdelen met 1/2. of schrijf zelf iets.

# namen van de directories waarnaartoe gesorteerd wordt
TA1=ta1
TA2=ta2

if [ -z "$1" ]; then
	echo Usage: specify fractional value
	exit 1
fi

N=$((`ls -d s* | wc -w` * $1))      # calculate integer amount for munin
N=${N%%.*}

SHUFFLED=$(
	for stud in s*; do
		echo $RANDOM $stud
	done | sort -k 1 | cut -d " " -f 2
)

mkdir -p $TA1
mkdir -p $TA2

mv `ls -df $SHUFFLED | head -$N` $TA2
mv s* $TA1 

