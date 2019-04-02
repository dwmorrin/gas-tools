if [ "$#" -ne 2 ]; then
    echo "usage: $(basename "$0") tag inputfile"
    exit 1
fi
tagname="$1"
filename="$2"
firstline=$(sed 1q "$filename")
# this prevents accidentally running the script on a file that doesn't need it
if [[ $firstline =~ $tagname ]]; then
  echo "$(basename "$0"): found $tagname in first line of $filename, aborting"
  exit 1
fi
# shellcheck disable=SC1004
if sed -i '.bak' '
1i\
<'"$tagname"'>

$a\
</'"$tagname"'>
' "$filename"
then
    rm "$filename.bak"
fi

exit 0
