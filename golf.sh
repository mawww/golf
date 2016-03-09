#!/bin/bash

count_keys() {
    str=$(echo "$1" | sed -r 's/<((c-.|a-.)|(c-|a-)?(ret|space|tab|lt|gt|backspace|esc|up|down|left|right|pageup|pagedown|home|end|backtab|del))>|./0/g')
    echo ${#str}
}

color_seq() {
    printf '\033[00;%sm' "$1"
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
           echo "${challenge_url} $(color_seq 31)FAIL$(color_seq 33) (in, out or cmd file missing)$(color_seq 00)"
           cd ..
           continue
        fi

        cp in test
        kak test -u -n -e "map global user q :wq<ret>; exec '$(cat cmd | sed -e s/\'/\\\\\'/g)'; exec i 'did not quit' <esc>; wq"
        key_count=$(count_keys "$(<cmd)")
        if [ -f vgscore ]; then
           vim_score=$(cat vgscore)
           vim_text=", vim $vim_score)"
        else
           vim_score=10000
           vim_text=""
        fi
        if cmp -s out test; then
            tag=OK
            color=32
            if [ "$vim_score" -lt $key_count ]; then
               color=35
            fi
        else
            tag=FAIL
            color=31
        fi
        echo "${challenge_url} $(color_seq $color)$tag$(color_seq 33) ($key_count keys$vim_text)$(color_seq 00)"
        cd ..
    fi
done
