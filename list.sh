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
path=""
sec="20"
#target="/usr/share/samdecrypt/.decrypt_userdata"
#M_OPTS="$PERM,usb=${USER},tvip=${PASSWD},codepage=cp1250,iocharset=utf8"
[ -e /usr/share/samdecrypt/.decrypt_userdata ] && source /usr/share/samdecrypt/.decrypt_userdata
[ -z $usb ] && exit 1
[ -z $tvip ] && exit 1
[ -z $path ] && exit 1
####################################################################################

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
function count_time()
{
seconds=$sec; date1=$((`date +%s` + $seconds)); 
while [ "$date1" -ne `date +%s` ]; do 
#  echo -ne "$(date -u --date @$(($date1 - `date +%s` )) +%H:%M:%S)\r"; 
  echo -ne "$(date -u --date @$(($date1 - `date +%s` )) +%S)\r";
done <<EOF
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
function del_tempfiles()
{
cd $path
rm -r infs
rm *.srf
rm *.key <<EOF
EOF
}
function get_file()
{
ftp -in $tvip <<EOF
cd /dtv/usb/$usb/CONTENTS/
binary
get $1
quit
EOF
}
function get_pvr_title()
{
	if [ ! -f "$1" ]
	then
		echo "No input file."
		exit -1;
	fi

	python -c  "f=open('$1','r');f.seek(0xff);print f.read(0x100).rstrip('\x00');"
}
function download_file()
{
wget "ftp://$tvip/dtv/usb/$usb/CONTENTS/$pvr.srf" -O $path/"$pvr.srf" 2>&1 | \
sed -u 's/^[a-zA-Z\-].*//; s/.* \{1,2\}\([0-9]\{1,3\}\)%.*/\1\n#Downloading... \1%/; s/^20[0-9][0-9].*/#Done./' | \
yad \
   --progress \
   --percentage=0 \
   --title="Samdecrypt" dialog \
   --window-icon="/usr/share/pixmaps/samdecrypt.png" \
   --text="Downloading encrypted recording files..." \
   --auto-close --auto-kill \ <<EOF
EOF
}
function decrypts_file()
{
2>&1 | \
sed -u 's/^[a-zA-Z\-].*//; s/.* \{1,2\}\([0-9]\{1,3\}\)%.*/\1\n#decrypt... \1%/; s/^20[0-9][0-9].*/#decrypted OK!./' | \
yad \
   --progress \
   --percentage=0 \
   --title="Download" dialog \
   --window-icon="/usr/share/pixmaps/samdecrypt.png" \
   --text="Downloading encrypted recording files..." \
   --auto-close --auto-kill \ <<EOF
EOF
}

#function wget()
#{
#tail -f /home/goran/Snimke/wgetlog
#}
#echo "Checking if drmdecrypt is already compiled."
#cd tools
#if [ -f "drmdecrypt" ]
#then
#	echo "File drmdecrypt already compiled. Skiping compilation."
#else
#	echo "File drmdecrypt doesn't exist. Compiling..."
#	make
#fi
#cd ..

#################################################################################################
echo "Deleting previously downloaded temp file if exist."
del_tempfiles
#################################################################################################
function list_video()
{
echo "Getting PVR list."
infs=`echo "ls /dtv/usb/$usb/CONTENTS/*.inf" | nc  -t -i 1 $tvip 23 | grep -o "/dtv/usb/$usb/CONTENTS/2.*inf" | grep -o "2.*inf"`
echo "Downloading PVR info files."

# && notify-send test "`tail /home/goran/Snimke/wgetlog`"
#mkdir ~/infs 2> /dev/null
mkdir $path/infs 2> /dev/null
#cd ~/infs
cd $path/infs
#menu_list=""
pvr_list=()
menu_list=()
cur_i=0
for i in $infs
do
	cur_i=$[cur_i + 1]
	get_file $i > /dev/null
	#cur_title=`get_pvr_title $i | tr ' ' '_' | tr '\t' '_'`
	cur_title=`get_pvr_title $i`
	menu_list+=("$cur_i")
	menu_list+=("$cur_title")
	pvr_list+=("${i%.*}")
	#menu_list="$menu_list $cur_i $cur_title"
	#if [ $cur_i -gt 10 ]
	#then
	#	break;
	#fi
	#echo $i
done
cd ..
echo "All PVR info files downloaded."
echo "Select PVR recording to download."
notify-send --app-name="Samdecrypt" --expire-time="9000" --icon="/usr/share/pixmaps/samdecrypt.png" "Title list of recorded files opened"
#menu_cmd="$menu_cmd $menu_list"
#$menu_cmd
#choice=$(dialog --menu "Select recording to download:" 25 80 25 "${menu_list[@]}" 2>&1 >/dev/tty)
#choice=$(zenity \
#    --title="Samdecrypt" \
#    --window-icon="/usr/share/pixmaps/samdecrypt.png" \
#    --text="Select encrypted recordings for download and decrypt" \
#    --list \
#    --column "Select" \
#    --column "recordings" \
#    "${menu_list[@]}") \
choice=$(yad \
    --title="Samdecrypt" --text="Title list of recorded video files"  \
    --width=400 \
    --height=200 \
    --image="/usr/share/pixmaps/samdecrypt-24.png" \
    --button="Close list:1" \
    --list \
    --column="#:NUM" \
    --column "File title:TEXT" \
    --no-click \
    "${menu_list[@]}") \

echo "Deleting tools from TV."
del_tools
notify-send --app-name="Samdecrypt" --expire-time="6000" --icon="/usr/share/pixmaps/samdecrypt.png" "Title list of recorded files closed"
echo ""
echo "All job is done "
 <<EOF
EOF
}

echo "Titlelist."
list_video
echo "Deleting tenp file."
del_tempfiles

exit
