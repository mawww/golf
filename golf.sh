#!/bin/bash

count_keys() {
    str=$(echo "$1" | sed -r 's/<((c-.|a-.)|(c-|a-)?(ret|space|tab|lt|gt|backspace|esc|up|down|left|right|pageup|pagedown|home|end|backtab|del))>|./0/g')
    echo ${#str}
}

if [ $# -eq 0 ]; then
    challenges=*
else
    challenges="$@"
fi

for challenge in ${challenges}; do
    if [[ -d ${challenge} ]]; then
        challenge_url="http://vimgolf.com/challenges/${challenge}"
        cd ${challenge}
        if [[ !( -f in && -f out && -f cmd ) ]]; then
           echo "Challenge ${challenge_url} FAILED (in, out or cmd file missing)"
           cd ..
           continue
        fi

        cp in test
        kak test -n -e "exec '$(<cmd)'; exec i 'did not quit' <esc>; wq"
        key_count=$(count_keys "$(<cmd)")
        if cmp -s out test; then
           echo "Challenge ${challenge_url} OK ($key_count keys)"
        else
           echo "Challenge ${challenge_url} FAIL ($key_count keys)"
        fi
        cd ..
    fi
done
