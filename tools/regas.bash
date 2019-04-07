#!/bin/bash
# helper script for working on Google Apps Script projects with clasp

progname="$(basename "$0")"

# check for presence of appropriate files first
if ! compgen -G "*."{js,css} >/dev/null; then
    echo "$(basename "$0") converts .js and .css to .html: no .js or .css found"
    exit 1
fi

quiet=false
while getopts "q" opt; do
    case "$opt" in
        q) quiet=true;;
       \?) echo "Usage: $progname [-q]"
           exit 1;;
    esac
done
shift $((OPTIND -1))

# note: compgen needs nullglob unset
shopt -s nullglob

noargs=false
if [[ $# -eq 0 ]]; then
    noargs=true
    # insert all .js and .css files in pwd as arguments, requires nullglob
    set -- *.{js,css}
fi

if ! $quiet && $noargs; then
    read -r -p "Convert all .js to .html and add <script> tags? [y/n]" confirmation
    if [ "$confirmation" != "y" ]; then
        exit 1
    fi
fi
    
for file; do
    ext="${file##*.}"
    case "$ext" in
        "js") tag="script";;
        "css") tag="style";;
        *)
        if ! $quiet; then
            echo "  Ignoring $file: does not appear to be js or css file"
        fi
        continue;;
    esac
    firstline=$(sed 1q "$file")
    if [[ $firstline =~ $tag ]]; then
        if ! $quiet; then
            echo "  Ignoring $file: already has $tag tag in first line"
        fi
        continue
    fi
    if ! $quiet; then
        read -r -p "Convert $file to .html with $tag tags? [y/n] " confirmation
        if [ "$confirmation" != "y" ]; then
            continue
        fi
    fi
    # shellcheck disable=SC1004
    if sed -i'.bak' '
1i\
<'"$tag"'>

$a\
</'"$tag"'>
' "$file"
    then
        rm "$file.bak"
    else
        echo "aborting: sed exited with error. Check for a .bak file."
        exit 1
    fi
    mv "$file" "${file%$ext}html"

done

exit 0
