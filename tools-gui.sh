#!/bin/bash

SAM_RUN=`yad \
           --class="Samdecrypt" \
           --name="Samdecrypt tools" \
           --window-icon="/usr/share/pixmaps/samdecrypt-84.png" \
           --icons \
           --item-width="84" \
           --read-dir="/usr/share/samdecrypt/desktopfiles3" \
           --width="330" \
           --height="230" \
           --borders=10 \
           --title="Samdecrypt" \
           --text="\n<b>Double click</b> on icon to start action:" \
           --button="Close:1"` \
