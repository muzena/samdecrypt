#!/bin/bash
#set -e
set -x  #debug

#Script for restaritng Samsung TV

####################################################################################

#echo "Checking and creating if it need user data file."
#FILE=~/.decrypt_userdata
#if [ -f $FILE ]; then
#   echo "File '$FILE' exists"
#else
#   echo 'usb="sda1"
#tvip="ENTER_YOUR_TV_IP"' > ~/.decrypt_userdata
#fi
echo "Selecting TV ip adress and recording devices."
usb=""
tvip=""
path=""
sec="20"
#target="/usr/share/samdecrypt/.decrypt_userdata"
#M_OPTS="$PERM,usb=${USER},tvip=${PASSWD},codepage=cp1250,iocharset=utf8"
[ -e /usr/share/samdecrypt/.decrypt_userdata ] && source /usr/share/samdecrypt/.decrypt_userdata
[ -z $usb ] && exit 1
[ -z $tvip ] && exit 1
[ -z $path ] && exit 1
####################################################################################

conf1="xterm -e 'ftp -in $tvip'"
conf2="xterm -e 'nc -t -i 1 $tvip 23'"
conf3="xterm -e 'telnet $tvip 23'"
conf4="xterm -e 'ssh root@$tvip'"

yad --info \
    --title="Samdecrypt warning" \
    --width=300 \
    --text="Terminal access, <b>ftp, netcat, telnet</b>. For <b>ssh</b> password is: <b>SamyGO</b> . <b>To enable ssh access read help!</b>" \
    --button="ftp:$conf1" \
    --button="netcat:$conf2" \
    --button="telnet:$conf3" \
    --button="ssh:$conf4" \
    --button="Close settings:1" \
    --kill-parent="1" \

exit
