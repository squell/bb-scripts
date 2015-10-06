#! /bin/sh

getsch.sh nodownload
if [ -e "bb.cookie" ] && [ -e "grades.csv" ]; then
    echo "Enter grades; empty line to finish"
    gencsv.sh >> grades.csv
    upload.sh grades.csv
else
    echo "Wuh?"
fi
