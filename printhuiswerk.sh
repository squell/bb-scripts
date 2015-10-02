#! /bin/sh

PRINTER=${1:-lazarus}
OPTIONS="-o PaperSources=PC210 -o Finisher=FS533 -o InputSlot=AutoSelect -o OutputBin=Default -o Binding=LeftBinding -o KMDuplex=2Sided -o SelectColor=Grayscale -o PageSize=A4 -o PageRegion=A4 -o Staple=1Staple(Left) -o Duplex=DuplexNoTumble -o OptionDuplex=True -o HPOption_Duplexer=True"

STUDDIRS="[sez][0-9][0-9]*"

lpq -P${PRINTER} | grep 'unknown' && exit 1
set -e

for pdf in ${STUDDIRS}/*.[pP][dD][fF]; do 
  studnr="${pdf%/*}"
  if [ ! -r "${pdf}.printed" ];
  then
    echo "$pdf"
    pdftops -paper A4 "$pdf" - | lpr -J "$studnr" -P${PRINTER} ${OPTIONS}
    touch "${pdf}.printed"
    sleep 3s
  else
    echo "$pdf al geprint"
  fi
done

