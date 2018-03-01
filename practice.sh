#/bin/bash

n=$1
example=$(ls | head -n$n | tail -n1)
cat $example/cmd
tmux split-window -h kak $(pwd)/$example/in
