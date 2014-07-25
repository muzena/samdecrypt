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
# notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Uploading widget to Samsung TV..."


choice=$(cd $widgetpath && ls *zip |  zenity \
				--title="Samdecrypt" \
				--window-icon="/usr/share/pixmaps/samdecrypt.png" \
				--text="\n<b>WARNING:</b> Select widget and then click <b>OK</b>. 
				\n<b>Clicking on selected item don't work!</b>" \
				--list \
				--width=300 \
				--height=350 \
				--column "Select widget") \

if [ $? = 1 ];
then exit
fi

function put_widget()
{
ftp -in $tvip <<EOF
lcd /usr/share/samdecrypt/tools
cd /mtd_rwcommon/widgets/user/
binary
put widget
lcd $widgetpath
put $choice 
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

if [ "$choice" ]
then
	put_widget
	copy_widget
fi

wait
notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Widget \"$choice\" is uploaded to Samsung TV"

yad \
  --title="Samdecrypt" \
  --window-icon="/usr/share/pixmaps/samdecrypt-24.png" \
  --width=260 \
  --height=90 \
  --text="Widget \"$choice\" is uploaded to Samsung TV" \
  --text-align="center" \
  --button="Close:1" \

sleep 3


#echo "Exiting Samdecrypt for "
#count_time
#alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
#alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] $(alert_helper)"'
#sleep 20; alert

