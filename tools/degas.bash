#!/bin/bash
# helper script for working on Google Apps Script projects with clasp
# converts .html files starting with <script> into .tmp.js files
# converts .html files starting with <style> into .tmp.css files

interactive=false
noargs=false
progpath="$0"
progname="$(basename "$0")"
quiet=false
recursive=false
scriptPattern='<script>'
stylePattern='<style>'

die() {
  local message="$1"
  local errno="${2:-1}"
  echo "$message"
  exit "$errno"
}

# no args: find .clasp and run this program recursively from there
if [[ $# -eq 0 ]]; then
    while [[ ${PWD##$HOME} != "$PWD" ]] && \
        [[ $PWD != "$HOME" ]]; do
        if compgen -G ".clasp*" >/dev/null; then
            projectRoot="$PWD"
            break
        fi
        cd -P .. || die "Cannot find .clasp file to determine GAS project root"
    done

    if [[ -z $projectRoot ]]; then
        die "Cannot find .clasp file to determine GAS project root"
    fi

    "$progpath" -r
    exit 0
fi

while getopts "iqr" opt; do
    case "$opt" in
        i) interactive=true;;
        q) quiet=true;;
        r) recursive=true;;
       \?) die "Usage: $progname [-iqr] [dir] [files...]";;
    esac
done
shift $((OPTIND - 1))


if [[ $# -eq 1 ]] && [[ -d "$1" ]]; then
    targetDir="$1"
fi

if $recursive || [[ -n $targetDir ]]; then
    find "${targetDir:-$PWD}" -name '*.html' -print0 | xargs -0 "$progpath" -q
    exit 0
fi

if [[ $# -eq 0 ]]; then
    noargs=true
    # insert all .html files in pwd as arguments, or null if no .html found
    shopt -s nullglob
    set -- *.html
fi

if [[ $# -eq 0 ]]; then
    die "$progname converts .html to .js or .css: no .html found"
fi

if ! $quiet && $noargs; then
    read -r -p "Convert all .html to .js or .css and remove html tags? [y/n] "\
        confirmation
    if [[ $confirmation != [Yy] ]]; then
        exit 1
    fi
fi

for file; do
    unset ext
    while read -r line; do
        lineno=$((lineno + 1))
        if [[ -n $line ]]; then
            break
        fi
    done <"$file"
    if [[ $line =~ $scriptPattern ]]; then
        ext="js"
        tag="script"
    elif [[ $line =~ $stylePattern ]]; then
        ext="css"
        tag="style"
    fi
    if [[ -n $ext ]]; then
        if $interactive; then
            read -r -p "Convert $file to $ext? [y/n] " confirmation
            if [[ $confirmation != [Yy] ]]; then
                continue
            fi
            echo "  Converting $file"
        fi
        if sed -i'.bak' '
            /^[[:space:]]*<\/*'"$tag"'>/d' "$file"; then
            rm "$file.bak"
        else
            die "aborting: sed exited with error. check for a .bak file."
        fi
        mv "$file" "${file%html}tmp.$ext"
    elif $interactive; then
        cat <<EOF
Ignoring $file: expected <script> or <style> in first line.
Found: $file: line $lineno: $line
Check rules on wiki page.
Open a new issue if you expected $file to work.
EOF
    fi
done

exit 0
