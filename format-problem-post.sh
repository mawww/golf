#!/bin/bash

url="http://www.vimgolf.com/challenges/$1"

curl -s -L -H 'Accept: text/html' "${url}" |
  kak -f '/<lt>h3<gt><ret>?<lt>h4<gt><ret>y%R' |
  kak -f 's<lt>h5<gt>(.*?)<lt>/h5<gt><ret><esc>c<c-r>1:<esc>' |
  kak -f 's<lt>pre[^<gt>]*<gt><ret>c```<ret><esc>' |
  kak -f 's<lt>/pre<gt><ret>c```<ret><esc>' |
  kak -f 's<lt>[^<gt>]*<gt><ret>d' |
  kak -f 'gki**<esc>A**<esc><a-o>2j<a-o>' |
  kak -f 'O'"${url}"'<ret><esc>'
