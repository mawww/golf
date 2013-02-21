#!/bin/bash

count_keys() {
    str=$(echo "$1" | sed -r 's/<((c-.|a-.)|(c-|a-)?(space|ret|esc|up|down|left|right))>|./0/g')
    echo ${#str}
}

for challenge in *; do
    if [[ -d ${challenge} ]]; then
        cd ${challenge}
        if [[ !( -f in && -f out && -f cmd ) ]]; then
           echo "Challenge ${challenge} FAILED (in, out or cmd file missing)"
           cd ..
           continue
        fi

        cp in test
        kak test -n -e "exec '$(<cmd)'; exec idid<space>not<space>quit<esc>; wq"
        key_count=$(count_keys "$(<cmd)")
        if cmp -s out test; then
           echo "Challenge http://vimgolf.com/challenges/${challenge} OK ($key_count keys)"
        else
           echo "Challenge http://vimgolf.com/challenges/${challenge} FAIL ($key_count keys)"
        fi
        cd ..
    fi
done
