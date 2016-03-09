#!/bin/bash

# count maakt het toedelen van punten makkelijker.
# Vul je feedback met dingen als -4 om punten af te trekken. Draai
# dan count.sh om automatisch het aantal overgebleven punten te
# berekenen:
#
#   TOTAL=100 ./count.sh s*/s*.txt
#
# voor een totaal van 100 punten (de default).
#
# count.sh update de Current Grade regel (ook als daar al iets anders
# stond!) en voegt een 'Points: ..' regel aan het eind van de feedback
# toe met de berekening. Het script kan meerdere keren worden gedraaid,
# dan wordt de oude berekening overschreven. Het is hiervoor wel nood-
# zakelijk dat er niets onder wordt geschreven, want dit script ver-
# wijdert simpelweg de laatste 3 regels.
#
# Werkt niet met decimale getallen. + wordt niet herkend om bonus-
# punten toe te kennen.
#
# De regex gebruikt om punten te herkennen is \s\-\d+, dus er moet
# whitespace voor staan.

if [ -z "$TOTAL" ]; then
    TOTAL="100"
fi
echo "Using $TOTAL as total."

for f in "$@"; do
    # Calculate points
    SUM="$TOTAL$(sed -n -e '/^Feedback:/,$p' "$f" | grep -o '\s\-[[:digit:]]\+' "$f" | tr '\r\n' ' ' | sed 's/\s//g')"
    GRADE="$(echo $SUM | bc)"
    
    # Add calculation to the end of the feedback
    grep 'Points: ' "$f" >/dev/null
    if [ $? -eq 0 ]; then
        head -n -3 "$f" | sponge "$f"
    fi
    echo -e "\nPoints: $SUM = $GRADE.\n" >> "$f"

    # Overwrite grade
    sed "s/Current Grade:.*/Current Grade: $GRADE/g" "$f" | sponge "$f"
done

