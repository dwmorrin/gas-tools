#!/bin/bash
# helper script for working on Google Apps Script projects with clasp
# converts .html files starting with <script> into .js files
# converts .css files starting with <style> into .css files

interactive=false
noargs=false
progpath="$0"
progname="$(basename "$0")"
quiet=false
recursive=false
scriptPattern='<script>'
stylePattern='<style>'

while getopts "iqr" opt; do
    case "$opt" in
        i) interactive=true;;
        q) quiet=true;;
        r) recursive=true;;
       \?) echo "Usage: $progname [-iqr]"
           exit 1;;
    esac
done
shift $((OPTIND - 1))

if $recursive; then
    find . -name '*.html' -print0 | xargs -0 "$progpath" -q
    exit 0
fi

if [[ $# -eq 0 ]]; then
    noargs=true
    # insert all .html files in pwd as arguments, or null if no .html found
    shopt -s nullglob
    set -- *.html
fi

if [[ $# -eq 0 ]]; then
    echo "$progname converts .html to .js or .css: no .html found"
    exit 1
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
    firstline=$(sed 1q "$file")
    if [[ $firstline =~ $scriptPattern ]]; then
        ext="js"
        tag="script"
    elif [[ $firstline =~ $stylePattern ]]; then
        ext="css"
        tag="style"
    fi
    # test if ext is set, note [[ -v ]] not compat with stock MacOS /bin/bash
    if [[ -n ${ext+1} ]]; then
        if $interactive; then
            read -r -p "Convert $file to $ext? [y/n] " confirmation
            if [[ $confirmation != [Yy] ]]; then
                return
            fi
            echo "  Converting $file"
        fi
        if sed -i'.bak' '
            /<\/*'"$tag"'>/d' "$file"; then
            rm "$file.bak"
        else
            echo "aborting: sed exited with error. check for a .bak file."
            exit 1
        fi
        mv "$file" "${file%html}$ext"
    else
        echo "  Ignoring $file: expected <script> or <style> in first line."
        echo "  $file: line 1: $firstline"
        echo "  check rules on wiki page."
        echo "  open a new issue if you expected $file to work."
    fi
done

exit 0
