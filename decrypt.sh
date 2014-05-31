#!/bin/bash
set -e
#set -x  debug

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
#target="/usr/share/samdecrypt/.decrypt_userdata"
#M_OPTS="$PERM,usb=${USER},tvip=${PASSWD},codepage=cp1250,iocharset=utf8"
[ -e /usr/share/samdecrypt/.decrypt_userdata ] && source /usr/share/samdecrypt/.decrypt_userdata
[ -z $usb ] && exit 1
[ -z $tvip ] && exit 1
[ -z $path ] && exit 1
####################################################################################

function put_tools
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
function fix_permission
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
chmod 755 /mtd_rwcommon/samyGOso
exit
EOF
}
function get_file
{
ftp -in $tvip <<EOF
cd /dtv/usb/$usb/CONTENTS/
binary
get $1
quit
EOF
}
function get_pvr_title
{
	if [ ! -f "$1" ]
	then
		echo "No input file."
		exit -1;
	fi

	python -c  "f=open('$1','r');f.seek(0xff);print f.read(0x100).rstrip('\x00');"
}
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
echo "Getting PVR list."
infs=`echo "ls /dtv/usb/$usb/CONTENTS/*.inf" | nc  -t -i 1 $tvip 23 | grep -o "/dtv/usb/$usb/CONTENTS/2.*inf" | grep -o "2.*inf"`
echo "Downloading PVR info files."
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
#menu_cmd="$menu_cmd $menu_list"
#$menu_cmd
choice=$(dialog --menu "Select recording to download:" 25 80 25 "${menu_list[@]}" 2>&1 >/dev/tty)
clear
if [ "$choice" ]
then
	choice=$[choice - 1]
	#echo $choice
	pvr="${pvr_list[$choice]}"
	#echo "$pvr"
	pvr_title=`get_pvr_title "./infs/$pvr.inf"`
	echo "Uploading tools..."
	put_tools
	echo "Tools uploaded."
	echo "Fix permission..."
	fix_permission
	echo "Dumping keys..."
	echo "/mtd_rwcommon/samyGOso -p \`pidof exeTV || pidof exeDSP || pidof exeSBB\` -l /mtd_rwcommon/libPVRdumpkeys.so" | nc  -t -i 1 $tvip 23 
	echo "Waiting for TV to dumpkeys..."
	sleep 3
	echo "Downloadng PVR file titled: \"$pvr_title\"."
	get_file "$pvr.key"
	#get_file "$pvr.srf"
	#use wget to have nice progress bar :)
#	wget "ftp://$tvip/dtv/usb/$usb/CONTENTS/$pvr.srf" -O ~/"$pvr.srf"
	wget "ftp://$tvip/dtv/usb/$usb/CONTENTS/$pvr.srf" -O $path/"$pvr.srf"
	echo "Starting file decryption..."
#	echo "Your decoded video files are located in your Home folder."
#	decrypt ~/"$pvr.srf" ~/"$pvr_title.ts" ~/"$pvr.key"
	decrypt $path/"$pvr.srf" $path/"$pvr_title.ts" $path/"$pvr.key"
	echo "Decoding of \"$pvr_title\" is finished..."
        chown $USER:$USER *.ts
#	echo "$pvr_title"
	echo "\"$pvr_title\"   video file are located in   $path."
	rm "$pvr.srf"
	rm "$pvr.key"
fi
rm ./infs/*
rmdir ./infs/
	#multi_get="get 20140206111003.inf\r\nget 20140209191510.inf"
	#echo "Downloading PVR files."

sleep 15 #(sleep 15 seconds)
