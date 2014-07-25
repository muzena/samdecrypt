#!/bin/bash
#set -e
set -x  #debug


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

function get_widgetslist()
{
ftp -in $tvip <<EOF
lcd $widgetpath
cd /mtd_rwcommon/common/WidgetMgr/
binary
get info.xml
quit
EOF
}

function list_widget()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
cd /mtd_rwcommon/widgets/user/
ls -d * > list.txt
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
# make tar files for putting into tv
function maketar_file()
{
choice_id=$(awk 'BEGIN {FS="|" } { print $1 }' $widgetpath/id-1.txt)
choice_name=$(awk 'BEGIN {FS="|" } { print $1 }' $widgetpath/name-2.txt)
echo '#!/bin/bash' > $widgetpath/maketar
echo '#set -e' >> $widgetpath/maketar
echo 'set -x  #debug' >> $widgetpath/maketar
echo '' >> $widgetpath/maketar
echo tar cvf "$choice_name".tar \""$choice_id"_img\" >> $widgetpath/maketar
echo '' >> $widgetpath/maketar
echo 'wait' >> $widgetpath/maketar
#echo 'done' >> $widgetpath/maketar
}
function put_maketar()
{
ftp -in $tvip <<EOF
lcd $widgetpath
cd /mtd_rwcommon/widgets/normal/
binary
put maketar
quit
EOF
}
function execute_maketar()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
chmod 755 /mtd_rwcommon/widgets/normal/maketar
cd /mtd_rwcommon/widgets/normal/
sh maketar
exit
EOF
}
function get_widget()
{
ftp -in $tvip <<EOF
lcd $widgetpath
cd /mtd_rwcommon/widgets/normal/
binary
get "$choice_name".tar 
lcd 
quit
EOF
}
function remove_tmptv()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
cd /mtd_rwcommon/widgets/normal/
rm maketar
rm "$choice_name".tar
exit
EOF
}
function remove_tmppc()
{
cd $widgetpath
rm maketar
rm "$choice_name".tar
rm id.txt
rm id-1.txt
rm info.xml
rm name.txt
rm name-2.txt
rm name-3.txt
rm name-4.txt
rm name_id.txt
rm name-id.txt
rm name_id-2.txt
rm -r *_img
exit
}
function make_widget()
{
cd $widgetpath
#rm list.txt
tar -xvf "$choice_name".tar
#cd "$choice_name"
cd "$choice_id"_img
zip -r "$choice_name".zip ./
cp "$choice_name".zip $widgetpath
cd ..
}
#choice_widgname=$(awk 'BEGIN {FS="|" } { print $1 }' $widgetpath/name.txt)

#list_widget

#get_widgetlist

get_widgetslist

#remove_widgetlist

wait
cd $widgetpath

perl -ne 'if(m/name="(.*?)"/){ print $1 . "\n"; }' info.xml > name.txt   #Extract name=
perl -ne 'if(m/id="(.*?)"/){ print $1 . "\n"; }' info.xml > id.txt   #Extract id=
perl -pne 's/[ \t\r\f]+/_/g' name.txt > name-3.txt  #Remove spaces from widget name
paste name-3.txt id.txt > name_id.txt                       #Joins:  name= i  id=
wait
#######################################################################################################
awk '/[0-9]$/' name_id.txt > name_id-2.txt              #Remove user widgets
#perl -ne 'if(m/name="(.*?)"/){ print $1 . "\n"; }' name_id-2.txt > name-4.txt   #Extract name=
#awk '[[:alpha:]]*' name_id-2.txt > name-4.txt
#cat name_id-2.txt | grep -o '[0-9$]*' > name-4.txt
cut -f 1 name_id-2.txt > name-4.txt
#########################################################################################################

choice=$(cat $widgetpath/name-4.txt |  zenity \
				--title="Samdecrypt" \
				--window-icon="/usr/share/pixmaps/samdecrypt.png" \
				--width=300 \
				--height=400 \
				--text="\n<b>WARNING:</b> Select widget and then click <b>OK</b>. 
				\n<b>Clicking on selected item don't work!</b>" \
				--list \
				--column "Select widget") \

if [ $? = 1 ];
then
remove_tmppc
exit
fi

sed -n '/'$choice'/p' name_id-2.txt > name-id.txt                   #Print one line!
#cat name-id.txt | grep -o '[[:digit:]]*' > id-1.txt             #Extract ID!
cut -f 2 name-id.txt > id-1.txt
#cat name-id.txt | grep -o '[[:alpha:]]*' > name-2.txt             #Extract name!
#echo "$choice" > name-2.txt
cut -f 1 name-id.txt > name-2.txt


#if [ "$choice" ]
#then
# Make script for tar commpresion in TV
maketar_file
#fi
# Upload maketar script to TV
put_maketar
# Execute maketar script and make widget tar archive 
execute_maketar
# Download widget tar archive from TV to PC
get_widget
# Make widget zip archive
make_widget
wait
# Remove tnp files from TV
remove_tmptv
# Remove tmp files from PC
remove_tmppc


wait

notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Widget \"$choice\" is stored in \"$widgetpath\""

yad \
  --title="Samdecrypt" \
  --window-icon="/usr/share/pixmaps/samdecrypt-24.png" \
  --width=260 \
  --height=90 \
  --text="Widget \"$choice\" is stored in \"$widgetpath\"" \
  --text-align="center" \
  --button="Close:1" \



sleep 3





