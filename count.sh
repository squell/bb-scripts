#!/bin/sh

# TODO NEEDPORT
echo "count.sh/stats.sh is disabled while we transition to a new bright space"
exit

# count.sh makes distributing points easier.
# Fill your feedback with things as -4 to subtract points. Run count.sh to
# automatically calculate the rest of the points:
#   TOTAL=100 ./count.sh s*/s*.txt
# 100 points is the default.

# count.sh updates the Current Grade line (even when it does not say 'Needs
# Grading'!) and adds a 'Points: ...' line at the end of the feedback with the
# calculation. The script can be run multiple times; the old calculation will
# be overridden. Do not write stuff below the calculation as the script will
# just remove the last three lines.

# This does not work with decimal numbers.
# + is not recognised for bonus points, but do make a pull request.

# The regex to recognise points is \s\-\d+, so include whitespace before it.

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
    `which echo` -e "\nPoints: $SUM = $GRADE.\n" >> "$f"

    # Overwrite grade
    sed "s/Current Grade:.*/Current Grade: $GRADE/g" "$f" | sponge "$f"
done

