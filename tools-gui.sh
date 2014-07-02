#!/bin/bash

conf3="/usr/share/samdecrypt/reboot-tv"

SAM_RUN=`yad \
           --class="Samdecrypt" \
           --name="Samdecrypt tools" \
           --window-icon="/usr/share/pixmaps/samdecrypt-84.png" \
           --icons \
           --item-width="84" \
           --read-dir="/usr/share/samdecrypt/desktopfiles3" \
           --width="450" \
           --height="230" \
           --borders=10 \
           --title="Samdecrypt" \
           --text="\n<b>Double click</b> on icon to start action:" \
	   --buttons-layout=edge \
           --button="Reboot TV:$conf3" \
           --button="Close:1"` \
