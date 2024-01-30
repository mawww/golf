#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 <challenge id>"
    exit -1
fi

challenge=${1}

mkdir ${challenge}
if curl -L http://vimgolf.com/challenges/${challenge}.json > ${challenge}/json; then
    jq -j '.in.data'  < ${challenge}/json | sed 's/\r$//;$a\' > ${challenge}/in
    jq -j '.out.data' < ${challenge}/json | sed 's/\r$//;$a\' > ${challenge}/out
    rm ${challenge}/json
else
    rm -r ${challenge}
fi
