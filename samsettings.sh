#!/bin/bash
#set -e
set -x  debug

conf1="gksu samsettingsgui"
conf2="xterm samconfigure"
conf3="/usr/share/samdecrypt/reboot-tv"


yad --info \
    --title="Samdecrypt warning" \
    --width=300 \
    --text="Configure Samdecrypt, if <b>GUI settings</b> failed then use <b>CLI settings</b>" \
    --button="GUI settings:$conf1" \
    --button="CLI settings:$conf2" \
    --button="Reboot TV:$conf3" \
    --button="Close settings:1" \
    --kill-parent="1" \

exit




