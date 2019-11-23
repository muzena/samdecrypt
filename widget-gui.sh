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
echo "Make widget directory if doesn't exist."
mkdir $widgetpath

widgetfolder="xdg-open $widgetpath"

SAM_RUN=`yad \
           --class="Samdecrypt" \
           --name="Samdecrypt widget" \
           --window-icon="/usr/share/pixmaps/samdecrypt-84.png" \
           --icons \
           --item-width="84" \
           --read-dir="/usr/share/samdecrypt/desktopfiles2" \
           --width="450" \
           --height="230" \
           --borders=10 \
           --title="Samdecrypt" \
           --text="\n<b>Double click</b> on icon to start action:" \
	   --buttons-layout=edge \
           --button="Widget folder:$widgetfolder" \
           --button="Close:1"` \





