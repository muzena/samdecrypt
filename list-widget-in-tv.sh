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

function list_widget()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
cd /mtd_rwcommon/widgets/user/
ls > list.txt
exit
EOF
}
function get_widgetlist()
{
ftp -in $tvip <<EOF
lcd $widgetpath
cd /mtd_rwcommon/widgets/user/
binary
get list.txt
quit
EOF
}
function remove_widgetlist()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
cd /mtd_rwcommon/widgets/user/
rm list.txt
exit
EOF
}
function remove_widgetlist()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
cd /mtd_rwcommon/widgets/user/
rm list.txt
exit
EOF
}
function remove_widget()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
cd /mtd_rwcommon/widgets/user/
rm -r $choice
exit
EOF
}

#Genetate widget list
list_widget
#Download widget list to computer
get_widgetlist
# Remove widget list from TV
remove_widgetlist

choice=$(cat $widgetpath/list.txt | yad \
    --title="Samdecrypt" --text="Widget list on Samsung TV"  \
    --width=400 \
    --height=300 \
    --image="/usr/share/pixmaps/samdecrypt-24.png" \
    --button="Close list:1" \
    --list \
    --column "File title:TEXT") \

#if [ "$choice" ]
#then
#	remove_widget
#fi
# Remove widget list from computer
rm $widgetpath/list.txt

wait
notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Widget list on Samsung TV closed"

sleep 3


#echo "Exiting Samdecrypt for "
#count_time
#alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
#alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] $(alert_helper)"'
#sleep 20; alert

