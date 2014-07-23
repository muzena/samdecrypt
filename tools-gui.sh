#!/bin/bash
#set -e
set -x  debug

####################################################################################

#echo "Checking and creating if it need user data file."
#FILE=~/.decrypt_userdata
#if [ -f $FILE ]; then
#   echo "File '$FILE' exists"
#else
#   echo 'usb="sda1"
#tvip="ENTER_YOUR_TV_IP"' > ~/.decrypt_userdata
#fi
echo "Selecting TV ip address and recording devices."
usb=""
tvip=""
path=""
#target="/usr/share/samdecrypt/.decrypt_userdata"
M_OPTS="$PERM,usb=${USER},tvip=${PASSWD},codepage=cp1250,iocharset=utf8"
[ -e /usr/share/samdecrypt/.decrypt_userdata ] && source /usr/share/samdecrypt/.decrypt_userdata
[ -z $usb ] && exit 1
[ -z $tvip ] && exit 1
[ -z $path ] && exit 1

####################################################################################

conf3="/usr/share/samdecrypt/reboot-tv"
conf4="/usr/share/samdecrypt/poweroff-tv"
videofolder="xdg-open $path"

SAM_RUN=`yad \
           --class="Samdecrypt" \
           --name="Samdecrypt tools" \
           --window-icon="/usr/share/pixmaps/samdecrypt-84.png" \
           --icons \
           --item-width="84" \
           --read-dir="/usr/share/samdecrypt/desktopfiles3" \
           --width="600" \
           --height="230" \
           --borders=10 \
           --title="Samdecrypt" \
           --text="\n<b>Double click</b> on icon to start action:" \
	   --buttons-layout=edge \
           --button="Poweroff TV:$conf4" \
           --button="Reboot TV:$conf3" \
           --button="Config folder:$videofolder" \
           --button="Close:1"` \
