#!/bin/bash
# helper script for working on Google Apps Script projects with clasp

interactive=false
noargs=false
progname="$(basename "$0")"
progpath="$0"
quiet=false
recursive=false

while getopts "iqr" opt; do
    case "$opt" in
        i) interactive=true;;
        q) quiet=true;;
        r) recursive=true;;
       \?) echo "Usage: $progname [-iqr] [dir] [files...]"
           exit 1;;
    esac
done
shift $((OPTIND -1))

if [[ $# -eq 1 ]] && [[ -d "$1" ]]; then
    targetDir="$1"
fi

if $recursive || [[ -n ${targetDir+1} ]]; then
    find "${targetDir:-$PWD}" \( -name '*.js' -o -name '*.css' \) -print0 | xargs -0 "$progpath" -q
    exit 0
fi

if [[ $# -eq 0 ]]; then
    noargs=true
    # insert all .js and .css files in pwd as arguments, or null if files not found
    shopt -s nullglob
    set -- *.{js,css}
fi

if [[ $# -eq 0 ]]; then
    echo "$(basename "$0") converts .js and .css to .html: no .js or .css found"
    exit 1
fi

if ! $quiet && $noargs; then
    read -r -p "Convert all .js and .css to .html and add html tags? [y/n] " confirmation
    if [[ $confirmation != [Yy] ]]; then
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
    if $interactive; then
        read -r -p "Convert $file to .html with $tag tags? [y/n] " confirmation
        if [[ $confirmation != [Yy] ]]; then
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
