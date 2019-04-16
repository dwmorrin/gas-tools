#!/bin/bash
# clap is a wrapper for `clasp push` that can be called from
#   from anywhere in the project, not just the root folder

die() {
  echo "$1"
  exit 1
}

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

clasp push
