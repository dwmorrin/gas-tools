#!/bin/bash
# helper script for working on Google Apps Script projects with clasp

interactive=false
noargs=false
progname="$(basename "$0")"
progpath="$0"
quiet=false
recursive=false

die() {
  message="$1"
  errno="${2:-1}"
  echo "$message"
  exit "$errno"
}

# no args: find .clasp and run this program recursively from there
if [[ $# -eq 0 ]]; then
    shopt -s extglob
    while [[ ${PWD##$HOME} != "$PWD" ]] && \
        [[ $PWD != "$HOME" ]]; do
        if compgen -G ".+(clasp|regas)*" >/dev/null; then
            projectRoot="$PWD"
            break
        fi
        cd -P .. || die "Cannot find .clasp or .regas file to determine GAS project root"
    done
    shopt -u extglob

    if [[ -z $projectRoot ]]; then
        die "Cannot find .clasp file to determine GAS project root"
    fi

    args=(-r)
    if [[ -f .regasignore ]]; then
        args+=(-x .regasignore)
    else
        args+=(-i)
    fi
    "$progpath" "${args[@]}"
    exit 0
fi

while getopts "iqrx:" opt; do
    case "$opt" in
        i) interactive=true;;
        q) quiet=true;;
        r) recursive=true;;
        x) ignoreFile="$OPTARG";; # not user supplied
       \?) die "Usage: $progname [-iqr] [dir] [files...]";;
    esac
done
shift $((OPTIND - 1))

if [[ $# -eq 1 ]] && [[ -d "$1" ]]; then
    targetDir="$1"
fi

if $recursive || [[ -n $targetDir ]]; then
    if [[ $# -gt 0 ]]; then # prevent `-r filename`
      die "Usage: illegal combination of arguments. Perhaps a filename with -r?"
    fi
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
    elif $interactive; then
        if ! compgen -G ./*.tmp.* &>/dev/null; then
            echo "no .regasignore file or *.tmp.* files found."
            PS3="Select directory to look for *.tmp.* files or abort: "
            if compgen -G ./*/ &>/dev/null; then
                select dir in ./*/ "abort $progname"; do
                    if [[ $dir = "abort $progname" ]]; then
                        exit 1
                    fi
                    targetDir=$dir
                    break
                done
            fi
        fi
    fi
    find "${targetDir:-$PWD}" \( -name '*.tmp.js' -o -name '*.tmp.css' \) \
        "${ignore[@]}" -print0 | xargs -0 "$progpath" -q
    exit 0
fi

if [[ $# -eq 0 ]]; then
    noargs=true
    # insert all .js and .css files in pwd as arguments, or null if files not found
    shopt -s nullglob
    set -- *.tmp.{js,css}
fi

if [[ $# -eq 0 ]]; then
    die "$(basename "$0") converts .js and .css to .html: no .js or .css found"
fi

if ! $quiet && $noargs; then
    read -r -p "Convert all .js and .css to .html and add html tags? [y/n] " confirmation
    if [[ $confirmation != [Yy] ]]; then
        exit 1
    fi
fi
    
for file; do
    ext="${file##*.tmp.}"
    case "$ext" in
        "js") tag="script";;
        "css") tag="style";;
        *)
        if ! $quiet; then
            echo "  Ignoring $file: does not appear to be js or css file"
        fi
        continue;;
    esac
    read -r firstline <"$file"
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
        die "aborting: sed exited with error. Check for a .bak file."
    fi
    mv "$file" "${file%tmp.$ext}html"

done

exit 0
