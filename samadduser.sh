#!/bin/bash
set -x
# For every user in /home/ ...
for HOME_U in /home/*?; do

# Obtain the username
USER=$( basename ${HOME_U} )

# In case the user is active (exists in /etc/shadow) ...
#if [ $( grep -c "${USER}:.*:.*:.*:.*:.*:::" /etc/shadow ) == 1 ] \
#&& [ $( grep -c "${USER}:.*:.*:.*:.*:.*:/bin/.*sh" /etc/passwd ) == 1 ] \
#&& [ -d ${HOME_U}/.config ] \
#&& [ -d ${HOME_U} ]; then



#     goran:x:1000:1000:goran,,,:/home/goran:/bin/bash

#if [ $( grep -c "${USER}:.*:.*:.*:.*:.*:::" /etc/shadow ) == 1 ] \
#if [ $( grep -c "${USER}:.*:1000:1000:.*,,,:/home/${USER}:/bin/bash" /etc/passwd ) == 1 ] \
if [ $( grep -c "${USER}:.*:1000:1000:.*,,,:.*:/bin/bash" /etc/passwd ) == 1 ] \
&& [ -d ${HOME_U}/.config ] \
&& [ -d ${HOME_U} ]; then



# Making sure .config/your-package/ exists
#mkdir -p /home/${USER}/.config/gogogogo/

mkdir -p /home/${USER}/sam-up-tv-tools/
# with appropiate permissions
chown ${USER}:${USER} /home/${USER}/sam-up-tv-tools/
cd /home/${USER}/sam-up-tv-tools/
wget https://launchpad.net/~trebelnik-stefina/+archive/sam/+files/samdecrypt_1.0.8%7Eprecise.tar.gz
tar xfv samdecrypt_1.0.8~precise.tar.gz
cd samdecrypt
cp /usr/share/samdecrypt/put-tools-in-tv.sh /home/${USER}/sam-up-tv-tools/
bash put-tools-in-tv.sh
cd ..
cd ..
ls
rm -r sam-up-tv-tools
ls

fi
done
