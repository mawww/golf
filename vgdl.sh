#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 <challenge id>"
    exit -1
fi

challenge=${1}

mkdir ${challenge}
if curl http://vimgolf.com/challenges/${challenge}.json > ${challenge}/json; then
    jq -rj '.in.data' < ${challenge}/json > ${challenge}/in
    jq -rj '.out.data' < ${challenge}/json > ${challenge}/out
    rm ${challenge}/json
else
    rm -r ${challenge}
fi
