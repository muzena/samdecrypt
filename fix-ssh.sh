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

function download_files()
{
cd $widgetpath
wget https://github.com/muzena/samdecrypt/raw/widgets/widgets/dropbearmulti
wget https://github.com/muzena/samdecrypt/raw/widgets/widgets/01_02_telnet.init
}
function remove_oldscript()
{
nc  -t -i 1 $tvip 23 <<EOF
cd /mnt/etc/init.d/
rm 01_02_telnet.init
exit
EOF
}
function put_dropbearmulti()
{
ftp -in $tvip <<EOF
lcd $widgetpath
cd /mnt/opt/privateer/usr/sbin/
binary
put dropbearmulti
quit
EOF
}
function put_telescrypt()
{
ftp -in $tvip <<EOF
lcd $widgetpath
cd /mnt/etc/init.d/
binary
put 01_02_telnet.init
quit
EOF
}
function fixpreme_dropbearmulti()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
cd /mnt/opt/privateer/usr/sbin/
chmod 755 dropbearmulti
exit
EOF
}
function fixpreme_telscript()
{
nc  -t -i 1 $tvip 23 <<EOF
cd ..
cd /mnt/etc/init.d/
chmod +x 01_02_telnet.init
exit
EOF
}
function remove_passwd()
{
nc  -t -i 1 $tvip 23 <<EOF
cd /mnt/bin/
umount /mtd_rwarea/passwd
rm /mtd_rwarea/passwd
exit
EOF
}
function make_symlinks()
{
telnet $tvip 23 <<EOF
chmod +x /mnt/opt/privateer/usr/sbin/dropbearmulti
rm /mnt/opt/privateer/usr/sbin/dropbear
ln -s /mnt/opt/privateer/usr/sbin/dropbearmulti /mnt/bin/dbclient
ln -s /mnt/opt/privateer/usr/sbin/dropbearmulti /mnt/bin/scp
ln -s /mnt/opt/privateer/usr/sbin/dropbearmulti /mnt/opt/privateer/usr/sbin/dropbear
quit
EOF
}
function remove_tmppc()
{
rm 01_02_telnet.init
rm dropbearmulti
}
function enable_sshscript()
{
nc  -t -i 1 $tvip 23 <<EOF
cd /mnt/etc/init.d/
cp 03_03_sshd.init.dis 03_03_sshd.init
chmod +x 03_03_sshd.init
/mnt/etc/init.d/03_03_sshd.init start
exit
EOF
}
function reboot_tv()
{
nc -t -i 1 $tvip 23 <<EOF
micom reboot
exit
EOF
}


#   Download files from web
download_files
#   Remove telnet script
# remove_oldscript
#   Upload dropbearmulti file to TV
put_dropbearmulti
#   Upload telnet script file to TV
put_telescrypt
#   Fix permission dropbearmulti file
fixpreme_dropbearmulti
#   Fix permission telnet script file
fixpreme_telscript
#   Remove /mtd_rwarea/passwd file
remove_passwd
#   Make symlinks
make_symlinks
#   Remove tmp files from PC
remove_tmppc
#   Enable SSH script
enable_sshscript
wait
#   Reboot TV
#reboot_tv

notify-send --app-name="Samdecrypt" --expire-time="3000" --icon="/usr/share/pixmaps/samdecrypt.png" "ssh connection fixed"

yad \
  --title="Samdecrypt" \
  --window-icon="/usr/share/pixmaps/samdecrypt-24.png" \
  --width=260 \
  --height=90 \
  --text="ssh connection fixed" \
  --text-align="center" \
  --button="Close:1" \



sleep 3





