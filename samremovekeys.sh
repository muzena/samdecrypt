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
echo "Selecting TV ip adress and recording devices."
usb=""
tvip=""
#target="/usr/share/samdecrypt/.decrypt_userdata"
#M_OPTS="$PERM,usb=${USER},tvip=${PASSWD},codepage=cp1250,iocharset=utf8"
[ -e /usr/share/samdecrypt/.decrypt_userdata ] && source /usr/share/samdecrypt/.decrypt_userdata
[ -z $usb ] && exit 1
[ -z $tvip ] && exit 1

####################################################################################
notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Deleting *.key files"

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
function del_keys()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
rm /dtv/usb/sda1/CONTENTS/*.key
rm /dtv/usb/sdb1/CONTENTS/*.key
rm /dtv/usb/sdc1/CONTENTS/*.key
rm /dtv/usb/sda2/CONTENTS/*.key
rm /dtv/usb/sdb2/CONTENTS/*.key
rm /dtv/usb/sdc2/CONTENTS/*.key
rm /dtv/usb/sda3/CONTENTS/*.key
rm /dtv/usb/sdb3/CONTENTS/*.key
rm /dtv/usb/sdc3/CONTENTS/*.key
exit
EOF
}
echo "Uploading tools..."
#put_tools
echo "Tools uploaded."
echo "Fix permission..."
#fix_permission
echo "Dumping keys..."

function generate_keys()
{
echo "/mtd_rwcommon/samyGOso -p \`pidof exeTV || pidof exeDSP || pidof exeSBB\` -l /mtd_rwcommon/libPVRdumpkeys.so" | nc  -t -i 1 $tvip 23 
 <<EOF
EOF
}

#generate_keys
notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "****.key files are deleted"
echo "Waiting for TV to dumpkeys..."
echo "Deleting tools from TV."
del_keys

yad \
  --title="Samdecrypt" \
  --window-icon="/usr/share/pixmaps/samdecrypt-24.png" \
  --width=260 \
  --height=90 \
  --text="*.key files are deleted" \
  --text-align="center" \
  --button="Quit:1" \

echo "#######################################"
echo "###                                 ###"
echo "###   Video keys are deleted ...    ###"
echo "###                                 ###"
echo "#######################################"
echo "############################################################################"
sleep 3
