#!/bin/bash

######################################################################################################
# Summary:                                                                                           #
#   - Installs Microsoft Edge for Linux                                                              #
#   - Installs Smart Card tools for Linux                                                            #
#   - Adds CAC (Smart Card) module support to Chromium based browsers (Chrome, Edge, Chromium, etc.) #
#   - Adds CAC (Smart Card) module support to Firefox browser                                        #
#   - Downloads latest DoD Certificates from cyber.mil                                               #
#   - Extracts and converts DoD certs to usable format                                               #
#   - Imports all DoD Root and Intermediate CAs into Chromium based browsers                         #
#   - Imports all DoD Root and Intermediate CAs into Firefox browser                                 #
#   - Imports all DoD Root and Intermediate CAs into base OS cert store                              #
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
sudo apt install microsoft-edge-beta -y

# Add CAC support to Chromium based browsers
mkdir -p $HOME/.pki/nssdb
chmod 700 $HOME/.pki
chmod 700 $HOME/.pki/nssdb
echo 'add cac module to shared nss db'
modutil -force -create -dbdir sql:$HOME/.pki/nssdb
modutil -force -dbdir sql:$HOME/.pki/nssdb -add 'CAC Module' -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so

# Add CAC support to Firfox browser
firefox --headless &
sleep 3
killall /usr/lib/firefox/firefox
echo 'add cac module to firefox'
modutil -force -dbdir $HOME/.mozilla/firefox/*.default-release -add 'CAC Module' -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so

# Download certs zip from cyber.mil / unzip / changed to extracted contents dir
curl https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/certificates_pkcs7_DoD.zip -o certificates_pkcs7_DoD.zip
unzip certificates_pkcs7_DoD.zip -d dod-certs
pushd dod-certs/*/

# Convert from .p7b to .pem (all certs are concatenated into single file)
openssl pkcs7 -in Certificates_PKCS7_v*_DoD.pem.p7b -print_certs -out DoD_CAs.pem
# Remove blank lines from .pem
sed -i '/^$/d' DoD_CAs.pem
# Remove 'subject = ' lines from .pem
sed -i '/^subject.*$/d' DoD_CAs.pem
# Remove 'issuer = ' lines from .pem
sed -i '/^issuer.*$/d' DoD_CAs.pem

# Split concatenated file into separate files for each individual cert
csplit -z -f USGOV-CA- -b %02d.crt DoD_CAs.pem  '/-----BEGIN CERTIFICATE-----/' '{*}'

# Rename certs to reflect the Subject CN of the cert
for cert in $(ls USGOV-CA-*.crt)
do
    # get cert name (i.e Suject CN)
    cert_name=$(openssl x509 -in $cert -noout -text | egrep '^.*Subject:.*$' | sed -r 's/^.*CN = (.*)$/\1/g' | sed -r 's/ /_/g')
    mv $cert $cert_name.crt
done

# Copy certs to system cert store (directory of files)
sudo cp *.crt /usr/share/ca-certificates/.
# Update system ca certs
sudo update-ca-certificates

# Import certs into Browser cert stores
for cert in $(ls *.crt)
do
    # get cert name (i.e Suject CN)
    cert_name=$(openssl x509 -in $cert -noout -text | egrep '^.*Subject:.*$' | sed -r 's/^.*CN = (.*)$/\1/g' | sed -r 's/ /_/g')
    # Import into Chromium based browsers cert store
    echo "add $cert_name to shared nss db"
    certutil -A -n $cert_name -t "CT,C,C" -d sql:$HOME/.pki/nssdb -i $cert
    # Import into Firefox browser cert store
    echo "add $cert_name to firefox"
    certutil -A -n $cert_name -t "CT,C,C" -d $HOME/.mozilla/firefox/*.default-release -i $cert
done

# Clean-up
popd
rm -rf dod-certs certificates_pkcs7_DoD.zip
