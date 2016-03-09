#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 <challenge id>"
    exit -1
fi

challenge=${1}

curl -s --header 'Accept: text/html,application/xhtml' -L "http://www.vimgolf.com/challenges/${challenge}" |
    kak -f ':set buffer eolformat lf<ret>/<lt>h5<gt>Lead<ret>/<lt>b<gt><ret>ey%R' > ${challenge}/vgscore
