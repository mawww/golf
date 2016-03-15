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

better=0
same=0
worse=0
fail=0
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
        keys=$(cat cmd | sed -e "s/'/\\\\'/g")
        cmd="map global user q :wq<ret>
             try 'exec \'$keys\''
             exec i 'did not quit' <esc>
             wq"
        kak test -ui dummy -n -e "$cmd"
        key_count=$(count_keys "$(<cmd)")
        if [ -f vgscore ]; then
           vim_score=$(cat vgscore)
           vim_text=", vim $vim_score"
        else
           vim_score=10000
           vim_text=""
        fi
        if cmp -s out test; then
            tag=OK
            if [ "$vim_score" -lt $key_count ]; then
               color=35
               worse=$((worse+1))
            elif [ "$vim_score" -eq $key_count ]; then
               color=33
               same=$((same+1))
            else
                color=32
               better=$((better+1))
            fi
        else
            tag=FAIL
            color=31
           fail=$((fail+1))
        fi
        echo "${challenge_url} $(color_seq $color)$tag$(color_seq 33) ($key_count keys$vim_text)$(color_seq 00)"
        cd ..
    fi
done

echo
echo "-----------------------------"
echo "$(color_seq 32)$better Better"
echo "$(color_seq 33)$same Same"
echo "$(color_seq 35)$worse Worse"
echo "$(color_seq 31)$fail Fail$(color_seq 00)"
echo "-----------------------------"
