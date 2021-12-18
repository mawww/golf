#!/bin/bash

if [ $# -eq 0 ]; then
    challenges=*
else
    challenges="$@"
fi

for challenge in ${challenges}; do
    if [[ -d ${challenge} ]]; then
        echo "Reading vimgolf.com best score for ${challenge}"
        curl -s --header 'Accept: text/html,application/xhtml' \
            -L "http://www.vimgolf.com/challenges/${challenge}" |
            kak -f '/Leaderboard<ret>/<lt>a href.*?<gt><ret>/\d+<ret>y%R' >${challenge}/vgscore
    fi
done
