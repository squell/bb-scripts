#!/bin/sh
# Maakt een histogram van de cijfers

# De basic flag bepaalt of je de hoeveelheden ziet
BASIC=true
# De numeric flag bepaalt of je statistieken ziet
NUMERIC=true
# De uniq flag bepaalt of je de gegeven cijfers ziet
UNIQ=true
# De hist flag bepaalt of je het histogram ziet
HIST=true
# De group flag bepaalt of je per groepje of per student een cijfer ziet
GROUP=false

if [ "$GROUP" = true ]; then
	GRADES="$(grep -ohP '(?<=Current Grade: ).*' "$@")"
else
	GRADES="$(for g; do yes "$(grep -oP '(?<=Current Grade: ).*' "$g")" |\
			head -n "$(grep -c 'Name: ' "$g")"; done)"
fi

if [ "$BASIC" = true ]; then
    count="$(echo "$GRADES" | wc -l)"
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

