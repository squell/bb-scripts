#!/usr/bin/env bash

if [! -f config.sh]; then
    echo "Expecting configuration in config.sh. Refer to the template file config_template.sh"
    exit 1
fi
# This will input/source the contents of the config.sh file, which
# will not be tracked by git.

. config.sh

for ta in "${!email[@]}"; do
        if [ ! -d "$ta" ]; then
                echo "$ta doesn't exist. Run verdeel.sh first."
                exit
        fi
done

for cmd in 7za mutt; do
        if ! command -v $cmd >/dev/null 2>&1; then
                echo "Who am I? Why am I here? Am I on lilo? $cmd is missing!" >& 2
                exit 1
        fi
done

for ta in "${!email[@]}"
do
    if [ "${email[$ta]}" ]; then
        echo Mailing "$ta"
        pkt="$ta-${zip%.zip}.7z"
        7za a -ms=on -mx=9 "$pkt" "$ta" > /dev/null
        #echo "" | mailx -n -s "${SUBJECT} ${zip%.zip}" -a "$pkt" "${email[$ta]}" 
        echo "" | mutt -s "${SUBJECT}: ${zip%.zip}" -a "$pkt" -- "${email[$ta]}" 
        rm -f "$pkt"
    fi
done
