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
ls -d * > list.txt
exit
EOF
}
function remove_tvconfig()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
cd /mtd_rwarea
rm FineTune_Digital
rm FineTune_Digitalb
rm LNBSettingsDataBase.dat
rm LNBSettingsDataBase.datb
rm map-AirA
rm map-AirAb
rm map-AirD
rm map-AirDb
rm map-CableD
rm map-CableDb
rm map-ChKey
rm map-ChKeyb
rm PackageDataBase.dat
rm PackageDataBase.datb
rm RadioMap
rm RadioMapb
rm SatDataBase.dat
rm SatDataBase.datb
rm ServiceProviders
rm ServiceProvidersb
rm TransponderDataBase.dat
rm TransponderDataBase.datb
rm TSIDList
rm TSIDListb
rm UserTransponderDataBase.dat
rm UserTransponderDataBase.datb
exit
EOF
}
################################################################################################
# make makezip files for putting into tv
function put_tvconfig()
{
ftp -in $tvip <<EOF
lcd $path/tv-config
cd /mtd_rwarea
binary
put FineTune_Digital
put LNBSettingsDataBase.dat
put map-AirA
put map-AirD
put map-CableD
put map-ChKey
put PackageDataBase.dat
put RadioMap
put SatDataBase.dat
put ServiceProviders
put TransponderDataBase.dat
put TSIDList
put UserTransponderDataBase.dat
quit
EOF
}
function unpack_scmconfig()
{
cd $path
cp tv-config.scm -t $path/tv-config
cd tv-config
unzip tv-config.scm
}

mkdir $path/tv-config

# remove tvconfig from TV
remove_tvconfig
# make zip archive for config files
unpack_scmconfig
# get config files from TV
put_tvconfig
# Remove tmp files
rm -r $path/tv-config
wait

notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Samsung TV configuration is imported to TV"

videofolder="xdg-open $path"
conf3="/usr/share/samdecrypt/reboot-tv"

yad \
  --title="Samdecrypt" \
  --window-icon="/usr/share/pixmaps/samdecrypt-24.png" \
  --width=260 \
  --height=90 \
  --text="Samsung TV configuration is imported to TV" \
  --text-align="center" \
  --button="Open configuration folder:$videofolder" \
  --button="Reboot TV:$conf3" \
  --button="Close:1" \



sleep 3


#echo "Exiting Samdecrypt for "
#count_time
#alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
#alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] $(alert_helper)"'
#sleep 20; alert
