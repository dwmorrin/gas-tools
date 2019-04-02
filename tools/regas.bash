#!/bin/bash
# requires chext.sh and addtags.sh
# helper script for working on Google Apps Script projects with clasp
progname="$(basename "$0")"
# check for presence of appropriate files first
if ! compgen -G "*.js" >/dev/null; then
    echo "$(basename "$0") chexts all .js to .html: no .js found"
    exit 1
fi

# without arguments: process all matching files in pwd
if [ "$#" -eq 0 ]; then
    read -r -p "Convert all .js to .html and add <script> tags? [y/n]" confirmation
    if [ "$confirmation" != "y" ]; then
        exit 1
    fi
    
    chext js html 
    for file in *.html; do
        addtags script "$file"
    done

    exit 0
fi

# with arguments: process only the listed files
for file; do
    if [ "${file##*.}" != js ]; then
        echo "$file is not .js, cannot covert with $progname, aborting"
        exit 1
    fi
    read -r -p "Convert $file to .html and add <script> tags? [y/n]" confirmation
    if [ "$confirmation" != "y" ]; then
        exit 1
    fi

    chext js html "$file"
    addtags script "${file%js}html"

    shift
done
exit 0
