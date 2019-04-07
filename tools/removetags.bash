#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "usage: $(basename "$0") tag inputfile"
    exit 1
fi
tagname="$1"
filename="$2"
if sed -i'.bak' '
/<\/*'"$tagname"'>/d' "$filename"
then
    rm "$filename.bak"
fi
exit 0
