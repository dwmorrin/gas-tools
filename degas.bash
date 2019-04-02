# requires chext.sh and removetags.sh
# helper script for working on Google Apps Script projects with clasp
progname="$(basename "$0")"
# check for presence of appropriate files first
if ! compgen -G "*.html" >/dev/null; then
    echo "$progname chexts all .html to .js: no .html found"
    exit 1
fi
# without arguments: process all matching files in pwd
if [ "$#" -eq 0 ]; then
    read -r -p "Convert all .html to .js and remove <script> tags? [y/n]" confirmation
    if [ "$confirmation" != "y" ]; then
        exit 1
    fi

    chext html js
    for file in *.js; do
        removetags script "$file"
    done

    exit 0
fi
# with arguments: process only the listed files
for file; do
    if [ "${file##*.}" != html ]; then
        echo "$file is not .html, cannot covert with $progname, aborting"
        exit 1
    fi
    read -r -p "Convert $file to .js and remove <script> tags? [y/n]" confirmation
    if [ "$confirmation" != "y" ]; then
        exit 1
    fi

    chext html js "$file"
    removetags script "${file%html}js"
done
exit 0
