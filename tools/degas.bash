#!/bin/bash
# helper script for working on Google Apps Script projects with clasp
# converts .html files starting with <script> into .js files
# converts .css files starting with <style> into .css files

progname="$(basename "$0")"

# check for presence of appropriate files first
if ! compgen -G "*.html" >/dev/null; then
    echo "$progname converts .html to .js or .css: no .html found"
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
    # insert all .html files in pwd as arguments
    set -- *.html
fi

if ! $quiet && $noargs; then
    read -r -p "Convert all .html to .js or .css and remove html tags? [y/n] " confirmation
    if [ "$confirmation" != "y" ]; then
        exit 1
    fi
fi

scriptPattern='<script>'
stylePattern='<style>'
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
    # test if ext is set, note [[ -v ]] not compatible on stock MacOS bash
    if [ -n "${ext+1}" ]; then
        if ! $quiet; then
            read -r -p "Convert $file to $ext? [y/n] " confirmation
            if [ "$confirmation" != "y" ]; then
                continue
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
    elif ! $quiet; then
        echo "  Ignoring $file: expected <script> or <style> in first line."
        echo "  $file: line 1: $firstline"
        echo "  check rules on wiki page."
        echo "  open a new issue if you expected $file to work."
    fi
done

exit 0
