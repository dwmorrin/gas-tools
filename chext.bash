if [ "$#" -lt 2 ]; then
    echo "usage: $(basename "$0") ext1 ext2 [files ...]"
    echo "  ext1 files will become ext2 files"
    exit 1
fi
oldExt=$1
newExt=$2
if [ "$#" -eq 2 ]; then
    for file in *."$oldExt"; do
        mv "$file" "${file%$oldExt}$newExt"
    done
    exit 0
fi
shift 2
for file; do
    mv "$file" "${file%$oldExt}$newExt"
done
exit 0
