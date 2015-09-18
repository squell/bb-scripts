#!/bin/bash

#PRINTER=lazurite-printsmb
#PRINTER=pr-m1-03

PRINTER=${1}
OPTIONS="-o PaperSources=PC210 -o Finisher=FS533 -o InputSlot=AutoSelect -o OutputBin=Default -o Binding=LeftBinding -o KMDuplex=2Sided -o SelectColor=Grayscale -o PageSize=A4 -o PageRegion=A4 -o Staple=1Staple(Left)"

for X in *.{pdf,PDF}; do 
  echo "$X"
  Y=`echo "$X" | sed -e 's/.*\(s[0-9]\+\).*/\1/'`
  #echo "$Y"
  if [ ! -r "$X.printed" ];
  then
    pdftops "$X" - | lpr -J "$Y" -P${PRINTER} ${OPTIONS};
    touch "$X.printed"; 
    sleep 3s
  else
    echo "$X al geprint"
  fi
done

