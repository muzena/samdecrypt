#!/bin/bash
set -e
#set -x  debug

echo "Selecting TV ip address and recording devices."
usb=""
tvip=""
path=""
widgetpath=""
#target="/usr/share/samdecrypt/.decrypt_userdata"
#M_OPTS="$PERM,usb=${USER},tvip=${PASSWD},codepage=cp1250,iocharset=utf8"
[ -e /usr/share/samdecrypt/.decrypt_userdata ] && source /usr/share/samdecrypt/.decrypt_userdata
#[ -e /home/$USER/.config/samdecrypt/.decrypt_userdata ] && source /home/$USER/.config/samdecrypt/.decrypt_userdata
[ -z $usb ] && exit 1
[ -z $tvip ] && exit 1
[ -z $path ] && exit 1
[ -z $widgetpath ] && exit 1
####################################################################################


#!/bin/bash 
#first=$(zenity --title="Your's First Name" --text "What is your first name?" --entry) 
#zenity --info --title="Welcome" --text="Mr./Ms. $first" 
#last=$(zenity --title="Your's Last Name" --text "$first what is your last name?" --entry) 
#zenity --info --title="Nice Meeting You" --text="Mr./Ms. $first $last"

#IPTV=$(zenity --entry --text "Enter IPTV adress" --entry-text="192.168.5.5")
#echo "$IPTV" > go.txt



#zenity --forms --title="Configure Samsung TV" --text="Add new user" \
#   --add-entry="Enter rec dev" \
#   --add-entry="Enter IPTV adress" \
#   --add-entry="Enter path" \
#   --add-entry="Enter wid path" \ >> go.txt



frmdata=$(yad \
	--title "Samdecrypt settings" \
	--text="<b>Change required settings</b>" \
	--text-align="center" \
	--width="500" \
	--height="150" \
	--button="Ok:0" \
	--form \
	--field="Recording device" "$usb" \
	--field="Samsung TV IP address" "$tvip" \
	--field="Downloading and decoding path" "$path" \
	--field="Widget files path" "$widgetpath") \


frmaddr=$(echo $frmdata | awk 'BEGIN {FS="|" } { print $1 }')
frmname=$(echo $frmdata | awk 'BEGIN {FS="|" } { print $2 }')
frmpath=$(echo $frmdata | awk 'BEGIN {FS="|" } { print $3 }')
frmwipath=$(echo $frmdata | awk 'BEGIN {FS="|" } { print $4 }')

# add settings to configuration file

echo usb=\"$frmaddr\" > /usr/share/samdecrypt/.decrypt_userdata
echo tvip=\"$frmname\" >> /usr/share/samdecrypt/.decrypt_userdata
echo path=\"$frmpath\" >> /usr/share/samdecrypt/.decrypt_userdata
echo widgetpath=\"$frmwipath\" >> /usr/share/samdecrypt/.decrypt_userdata


notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Samdecrypt is configured"


