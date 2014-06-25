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
# notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "****.key files are generating"

function generate_keyfiles()
{
function put_tools()
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
function fix_permission()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
chmod 755 /mtd_rwcommon/samyGOso
exit
EOF
}
function del_tools()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
rm /mtd_rwcommon/samyGOso
rm /mtd_rwcommon/libPVRdumpkeys.so
exit
EOF
}
echo "Uploading tools..."
put_tools
echo "Tools uploaded."
echo "Fix permission..."
fix_permission
echo "Dumping keys..."

function generate_keys()
{
echo "/mtd_rwcommon/samyGOso -p \`pidof exeTV || pidof exeDSP || pidof exeSBB\` -l /mtd_rwcommon/libPVRdumpkeys.so" | nc  -t -i 1 $tvip 23 
 <<EOF
EOF
}

generate_keys

notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "*.key files are generated on recording device"
echo "Waiting for TV to dumpkeys..."
echo "Deleting tools from TV."
del_tools
}


function download_keys()
{
cd $path
wget "ftp://$tvip/dtv/usb/$usb/CONTENTS/*.key" <<EOF
EOF
}

# Generate key files
generate_keyfiles

wait

# Download key files to computer
download_keys

wait
notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "key files downloaded to computer"

yad \
  --title="Samdecrypt" \
  --window-icon="/usr/share/pixmaps/samdecrypt-24.png" \
  --width=260 \
  --height=90 \
  --text="key files downloaded to computer" \
  --text-align="center" \
  --button="Close:1" \



sleep 3


#echo "Exiting Samdecrypt for "
#count_time
#alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
#alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] $(alert_helper)"'
#sleep 20; alert

