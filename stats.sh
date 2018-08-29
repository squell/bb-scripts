#!/bin/sh

#TODO NEEDPORT
echo "count.sh/stats.sh is disabled while we transition to a new bright space"
exit

# Some statistics about the grades

BASIC=true    # How many students participated
NUMERIC=true  # Min, max, range, avg, standard dev. (only for numeric grades)
UNIQ=true     # Distribution of grades
HIST=true     # Histogram (only for numeric grades)
GROUP=false   # Whether grades are per group or per student

if [ "$GROUP" = true ]; then
	GRADES="$(grep -ohP '(?<=Current Grade: ).*' "$@")"
else
	GRADES="$(for g; do yes "$(grep -oP '(?<=Current Grade: ).*' "$g")" |\
			head -n "$(grep -c 'Name: ' "$g")"; done)"
fi

if [ "$BASIC" = true ]; then
	count="$(grep -ohP '^Current Grade:' "$@" | wc -l)"
    countstudents="$(grep 'Name:' "$@" | wc -l)"

    echo "$count assignments handed in."
    echo "$countstudents students participated."
    echo
fi

if [ "$NUMERIC" = true ]; then
    min="$(echo "$GRADES" | sort -g | head -n1)"
    max="$(echo "$GRADES" | sort -g | tail -n1)"
    range="$((max-min))"
    avg="$(echo "$GRADES" | awk '{s+=$1}END{print s/NR}')"
    svd="$(echo "$GRADES" | awk '{sum+=$1; sumsq+=$1*$1}END{print sqrt(sumsq/NR - (sum/NR)*(sum/NR))}')"

    echo "minimum:   $min"
    echo "maximum:   $max"
    echo "range:     $range"
    echo "average:   $avg"
    echo "svd:       $svd"
    echo
fi

if [ "$UNIQ" = true ]; then
    echo "Distribution:"
    echo "$GRADES" | sort -g | uniq -c
    echo
fi

if [ "$HIST" = true ]; then
    histmin=1
    histmax=100
    histstep=10

    echo "Histogram:"
    i=$histmin
    while [ $i -le $histmax ]; do
        printf '%4d: ' "$i"
        for g in $GRADES; do
            if [ $g -ge $i ] && [ $g -lt $((i+histstep)) ]; then
                echo -n "#"
            fi
        done
        echo
        i=$((i+histstep))
    done
    echo
fi

