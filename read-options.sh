#!/bin/bash
#set -e
set -x  debug

function settings_paths()
{
echo "Selecting TV ip address and recording devices."
usb=""
tvip=""
path=""
widgetpath=""
sec="20"
#target="/usr/share/samdecrypt/.decrypt_userdata"
#M_OPTS="$PERM,usb=${USER},tvip=${PASSWD},codepage=cp1250,iocharset=utf8"
[ -e /usr/share/samdecrypt/.decrypt_userdata ] && source /usr/share/samdecrypt/.decrypt_userdata
[ -z $usb ] && exit 1
[ -z $tvip ] && exit 1
[ -z $path ] && exit 1
[ -z $widgetpath ] && exit 1
}

####################################################################################

settings_paths

exit
