#!/bin/bash
set -x
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
#target="/usr/share/samdecrypt/.decrypt_userdata"
M_OPTS="$PERM,usb=${USER},tvip=${PASSWD},codepage=cp1250,iocharset=utf8"
[ -e /usr/share/samdecrypt/.decrypt_userdata ] && source /usr/share/samdecrypt/.decrypt_userdata
[ -z $usb ] && exit 1
[ -z $tvip ] && exit 1
[ -z $path ] && exit 1

####################################################################################

function put_tools
{
ftp -in $tvip <<EOF
lcd /usr/share/samdecrypt/tools
cd /mtd_rwcommon/
binary
put samyGOso
put libPVRdumpkeys.so
quit
EOF
}
echo "Uploading tools..."
put_tools
echo "Tools uploaded."
#echo "Dumping keys..."
#echo "/mtd_rwcommon/samyGOso -p \`pidof exeTV || pidof exeDSP\` -l /mtd_rwcommon/libPVRdumpkeys.so" | nc  -t -i 1 $tvip 23 
#echo "Waiting for TV to dumpkeys..."

sleep 3
