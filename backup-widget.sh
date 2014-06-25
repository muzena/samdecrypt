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
rm makezip
rm $choicewidget.tar
exit
EOF
}
function put_makezip()
{
ftp -in $tvip <<EOF
lcd $widgetpath
cd /mtd_rwcommon/widgets/user/
binary
put makezip
quit
EOF
}
function execute_makezip()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
chmod 755 /mtd_rwcommon/widgets/user/makezip
cd /mtd_rwcommon/widgets/user/
sh makezip
exit
EOF
}


#rm makezip
#Genetate widget list
list_widget
#Download widget list to computer
get_widgetlist
# Remove widget list from TV
#remove_widgetlist



choice=$(cat $widgetpath/list.txt |  zenity \
				--title="Samdecrypt" \
				--window-icon="/usr/share/pixmaps/samdecrypt.png" \
				--text="\n<b>WARNING:</b> Select widget and then click \n<b>OK</b>. \n<b>Clicking on selected item don't work</b>" \
				--list \
				--column "Select widget") \

if [ "$choice" ]
then
echo $choice > $path/choice.txt
fi

wait

# make makezip files for putting into tv
function makezip_file()
{
choicewidget=$(awk 'BEGIN {FS="|" } { print $1 }' $path/choice.txt)
echo '#!/bin/bash' > $widgetpath/makezip
echo '#set -e' >> $widgetpath/makezip
echo 'set -x  #debug' >> $widgetpath/makezip
echo '' >> $widgetpath/makezip
echo tar cvf $choicewidget.tar $choicewidget >> $widgetpath/makezip
#echo 'done' >> $widgetpath/makezip
}

function get_widget()
{
ftp -in $tvip <<EOF
lcd $widgetpath
cd /mtd_rwcommon/widgets/user/
binary
get $choicewidget.tar 
lcd 
quit
EOF
}

function make_widget()
{
cd $widgetpath
rm list.txt
tar -xvf $choicewidget.tar
cd $choicewidget
zip -r $choicewidget.zip ./
cp $choicewidget.zip $widgetpath
cd ..
rm -r $choicewidget
rm $choicewidget.tar
rm makezip
cd ..
cd $path
rm choice.txt
}



# making script for archiving widget in TV
makezip_file
# put script in TV
put_makezip
# making widget archive in TV
execute_makezip
# downloading widget archive from TV in widget path on computer
get_widget
# unpacking widget tar archive and making zip
make_widget
#remove files from TV

remove_widgetlist


wait
notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "Widget \"$choicewidget\" is stored in \"$widgetpath\""

yad \
  --title="Samdecrypt" \
  --window-icon="/usr/share/pixmaps/samdecrypt-24.png" \
  --width=260 \
  --height=90 \
  --text="Widget \"$choicewidget\" is stored in \"$widgetpath\"" \
  --text-align="center" \
  --button="Close:1" \



sleep 3


#echo "Exiting Samdecrypt for "
#count_time
#alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
#alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] $(alert_helper)"'
#sleep 20; alert

