#!/bin/bash
# helper script for working on Google Apps Script projects with clasp

interactive=false
noargs=false
progname="$(basename "$0")"
progpath="$0"
quiet=false
recursive=false

# no args: find .clasp and run this program recursively from there
if [[ $# -eq 0 ]]; then
    while [[ ${PWD##$HOME} != "$PWD" ]] && \
        [[ $PWD != "$HOME" ]]; do
        if compgen -G ".clasp*" >/dev/null; then
            projectRoot=$PWD
            break
        fi
        cd ..
    done

    if [[ -z $projectRoot ]]; then
        echo "Cannot find .clasp file to determine GAS project root"
        exit 1
    fi

    args=(-r)
    if [[ -f .regasignore ]]; then
        args+=(-x)
        args+=(.regasignore)
    fi
    "$progpath" "${args[@]}"
    exit 0
fi

while getopts "iqrx:" opt; do
    case "$opt" in
        i) interactive=true;;
        q) quiet=true;;
        r) recursive=true;;
        x) ignoreFile="$OPTARG";;
       \?) echo "Usage: $progname [-iqrx] [dir] [files...]"
           exit 1;;
    esac
done
shift $((OPTIND -1))

if [[ $# -eq 1 ]] && [[ -d "$1" ]]; then
    targetDir="$1"
fi

if $recursive || [[ -n $targetDir ]]; then
    if [[ -n $ignoreFile ]]; then
        comment='#'
        ignore=(-not \( -path "*.git*")
        while read -r line; do
            if [[ $line =~ $comment ]]; then
                continue
            fi
            ignore+=(-o -path "*""$line""*")
        done <"$ignoreFile"
        ignore+=(\))
    fi
    find "${targetDir:-$PWD}" \( -name '*.js' -o -name '*.css' \) \
        "${ignore[@]}" -print0 | xargs -0 "$progpath" -q
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
    if [[ $firstline =~ no-regas ]]; then
        if ! $quiet; then
            echo "  Ignoreing $file: has no-regas in first line"
        fi
        continue
    fi
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
