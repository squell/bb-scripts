#! /bin/sh

PRINTER=${1:-lazarus}
OPTIONS="-o PaperSources=PC210 -o Finisher=FS533 -o InputSlot=AutoSelect -o OutputBin=Default -o Binding=LeftBinding -o KMDuplex=2Sided -o SelectColor=Grayscale -o PageSize=A4 -o PageRegion=A4 -o Staple=1Staple(Left)"

STUDDIRS="[sez][0-9][0-9]*"

lpq -P${PRINTER} | grep 'unknown' && exit 1
set -e

for pdf in ${STUDDIRS}/*.[pP][dD][fF]; do 
  echo "$pdf"
  studnr="${pdf%/*}"
  if [ ! -r "${pdf}.printed" ];
  then
    pdftops "$pdf" - | lpr -J "$studnr" -P${PRINTER} ${OPTIONS}
    touch "${pdf}.printed"
    sleep 3s
  else
    echo "$pdf al geprint"
  fi
done

