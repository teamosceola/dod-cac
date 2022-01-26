#!/bin/bash

######################################################################################################
# Summary:                                                                                           #
#   - Installs Microsoft Edge for Linux                                                              #
#   - Installs Smart Card tools for Linux                                                            #
#   - Adds CAC (Smart Card) module support to Chromium based browsers (Chrome, Edge, Chromium, etc.) #
#   - Adds CAC (Smart Card) module support to Firefox browser                                        #
#                                                                                                    #
# *NOTE: Do NOT run script with 'sudo', run as regular user                                          #
######################################################################################################

# install needed tools
sudo apt install opensc libnss3-tools curl openssl -y

## Setup Microsoft Edge Repo
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-beta.list'
sudo rm microsoft.gpg

## Install Microsoft Edge
sudo apt update
sudo apt install microsoft-edge-stable -y

# Add CAC support to Chromium based browsers
mkdir -p $HOME/.pki/nssdb
chmod 700 $HOME/.pki
chmod 700 $HOME/.pki/nssdb
echo 'add cac module to shared nss db'
modutil -force -create -dbdir sql:$HOME/.pki/nssdb
modutil -force -dbdir sql:$HOME/.pki/nssdb -add 'CAC Module' -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
if [ -d $HOME/snap/chromium ]
then
    modutil -force -create -dbdir sql:$HOME/snap/chromium/current/.pki/nssdb
    modutil -force -dbdir sql:$HOME/snap/chromium/current/.pki/nssdb -add 'CAC Module' -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
fi

# Add CAC support to Firfox browser
firefox --headless &
sleep 10
killall $(ps a | grep 'firefox --headless' | grep -v grep | sed -r 's/^.* (\/.*) .*$/\1/g')
killall $(ps a | grep 'firefox-esr --headless' | grep -v grep | sed -r 's/^.* (\/.*) .*$/\1/g')
echo 'add cac module to firefox'
if [ -d $HOME/.mozilla/firefox ]
then
    for dir in $(ls -d $HOME/.mozilla/firefox/*.default*)
    do
        modutil -force -create -dbdir $dir
        modutil -force -dbdir $dir -add 'CAC Module' -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
    done
fi
if [ -d $HOME/snap/firefox ]
then
    for dir in $(ls -d $HOME/snap/firefox/common/.mozilla/firefox/*.default*)
    do
        modutil -force -create -dbdir $dir
        modutil -force -dbdir $dir -add 'CAC Module' -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
    done
fi