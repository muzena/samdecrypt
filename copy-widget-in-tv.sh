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
notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Uploading widget to Samsung TV..."


function put_widget()
{
ftp -in $tvip <<EOF
lcd /usr/share/samdecrypt/tools
cd /mtd_rwcommon/widgets/user/
binary
put widget
lcd $widgetpath
put *.zip 
quit
EOF
}
function copy_widget()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
chmod 755 /mtd_rwcommon/widgets/user/widget
cd /mtd_rwcommon/widgets/user/
sh widget
rm widget
exit
EOF
}

echo "Uploading widget..."
put_widget
echo "Adding widget..."
copy_widget

wait
notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Widget are uploaded to Samsung TV"

yad \
  --title="Samdecrypt" \
  --window-icon="/usr/share/pixmaps/samdecrypt-24.png" \
  --width=260 \
  --height=90 \
  --text="Widget are uploaded to Samsung TV" \
  --text-align="center" \
  --button="Close:1" \

sleep 3
