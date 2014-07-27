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
widgetpath=""
#target="/usr/share/samdecrypt/.decrypt_userdata"
#M_OPTS="$PERM,usb=${USER},tvip=${PASSWD},codepage=cp1250,iocharset=utf8"
[ -e /usr/share/samdecrypt/.decrypt_userdata ] && source /usr/share/samdecrypt/.decrypt_userdata
[ -z $usb ] && exit 1
[ -z $tvip ] && exit 1
[ -z $path ] && exit 1
[ -z $widgetpath ] && exit 1

####################################################################################
#echo "Make widget directory if doesn't exist."
mkdir $widgetpath

widgetfolder="xdg-open $widgetpath"

conf1="/usr/share/samdecrypt/copy-widget-in-tv.sh"
conf2="/usr/share/samdecrypt/copy-widget-in-tv-from-web.sh"
conf3="/usr/share/samdecrypt/reboot-tv"

yad --info \
    --title="Add widgets" \
    --width=300 \
    --text="Add widget, manual from <b>computer</b> or <b>web source</b>" \
    --button="Widget from PC:$conf1" \
    --button="Widget from web:$conf2" \
    --button="Reboot TV:$conf3" \
    --button="Close:1" \
    --kill-parent="1" \

exit



