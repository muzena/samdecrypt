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
echo "Make video directory if doesn't exist."
mkdir $path

videofolder="xdg-open $path"

conf1="/usr/share/samdecrypt/decrypt.sh"
conf2="/usr/share/samdecrypt/decrypt-shut-tv.sh"
conf3="/usr/share/samdecrypt/decrypt-shut-tv-shut-comp.sh"
conf4="/usr/share/samdecrypt/list.sh"
conf5="/usr/share/samdecrypt/decrypt-shut-comp.sh"

yad --info \
    --title="Decrypt video recordings" \
    --width=300 \
    --text="<b>Click</b> on selected button to take action" \
    --button="Decrypt video:$conf1" \
    --button="Decrypt, poweroff TV:$conf2" \
    --button="Decrypt, poweroff PC:$conf5" \
    --button="Decrypt, poweroff TV and PC:$conf3" \
    --kill-parent="1" \

exit



