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
function remove_widgetlist()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
cd /mtd_rwcommon/widgets/user/
rm list.txt
rm makezip
rm $choicewidget.tar
exit
EOF
}
################################################################################################
# make makezip files for putting into tv
function get_tvconfig()
{
ftp -in $tvip <<EOF
lcd $path/tv-config
cd /mtd_rwarea
binary
get FineTune_Digital
get map-AirA
get map-AirD
get map-CableD
get map-ChKey
get PackageDataBase.dat
get RadioMap
get SatDataBase.dat
get ServiceProviders
get TransponderDataBase.dat
get TSIDList
get UserTransponderDataBase.dat
quit
EOF
}
function make_scmconfig()
{
cd $path/tv-config
touch CloneInfo
echo HTO F-Serie > CloneInfo
zip -r tv-config.zip ./
cp tv-config.zip $path
cd ..
mv tv-config.zip tv-config.scm
rm -r tv-config
}

mkdir $path/tv-config
cd $path/tv-config

# get config files from TV
get_tvconfig
# make zip archive for config files
make_scmconfig


wait
notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Samsung TV configuration is stored in \"$path\""

videofolder="xdg-open $path"

yad \
  --title="Samdecrypt" \
  --window-icon="/usr/share/pixmaps/samdecrypt-24.png" \
  --width=260 \
  --height=90 \
  --text="scm channel and TV configuration file is stored in \"$path\" you can open scm file in Samtoolbox channel editor or some other channel editor" \
  --text-align="center" \
  --button="Open configuration folder:$videofolder" \
  --button="Open Samtoolbox editor:"samtoolbox"" \
  --button="Close:1" \



sleep 3


#echo "Exiting Samdecrypt for "
#count_time
#alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
#alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] $(alert_helper)"'
#sleep 20; alert

