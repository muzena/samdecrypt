#!/bin/bash

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

function put_tools
{
ftp -in $tvip <<EOF
lcd tools
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
echo "Dumping keys..."
echo "/mtd_rwcommon/samyGOso -p \`pidof exeTV || pidof exeDSP\` -l /mtd_rwcommon/libPVRdumpkeys.so" | nc  -t -i 1 $tvip 23 
echo "Waiting for TV to dumpkeys..."
echo "#######################################"
echo "###                                 ###"
echo "###   Video keys are generated...   ###"
echo "###                                 ###"
echo "#######################################"
echo "############################################################################"
echo "####                                                                     ###"
echo "####    Discconect recording device from your TV and connect it to PC,   ###"
echo "####    then in terminal type this command:                              ###"
echo "####    decrypt /Path_to_your_video_files/Name_of_your_srf_file.srf      ###"
echo "####     /Path_to_destination_folder/Name_for_your_decrypted_file.ts     ###"
echo "####     /Path_to_your_video_files/Name_of_your_key_file.key             ###"
echo "####                                                                     ###"
echo "############################################################################"
sleep 3
