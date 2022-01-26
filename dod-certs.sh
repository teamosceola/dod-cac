#!/bin/bash

######################################################################################################
# Summary:                                                                                           #
#   - Downloads latest DoD Certificates from cyber.mil                                               #
#   - Extracts and converts DoD certs to usable format                                               #
#   - Imports all DoD Root and Intermediate CAs into Chromium based browsers                         #
#   - Imports all DoD Root and Intermediate CAs into Firefox browser                                 #
#   - Imports all DoD Root and Intermediate CAs into base OS cert store                              #
#                                                                                                    #
# *NOTE: Do NOT run script with 'sudo', run as regular user                                          #
######################################################################################################

# Download certs zip from cyber.mil / unzip / changed to extracted contents dir
curl https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/certificates_pkcs7_DoD.zip -o certificates_pkcs7_DoD.zip
unzip certificates_pkcs7_DoD.zip -d dod-certs
pushd dod-certs/*/

# Convert from .p7b to .pem (all certs are concatenated into single file)
mkdir tmp
openssl pkcs7 -in Certificates_PKCS7_v*_DoD.pem.p7b -print_certs -out tmp/DoD_CAs.pem
pushd tmp

# Remove blank lines from .pem
sed -i '/^$/d' DoD_CAs.pem
# Remove 'subject = ' lines from .pem
sed -i '/^subject.*$/d' DoD_CAs.pem
# Remove 'issuer = ' lines from .pem
sed -i '/^issuer.*$/d' DoD_CAs.pem

# Split concatenated file into separate files for each individual cert
csplit -z -f USGOV-CA- -b %02d.pem DoD_CAs.pem  '/-----BEGIN CERTIFICATE-----/' '{*}'
rm DoD_CAs.pem

# Rename certs to reflect the Subject CN of the cert, replacing spaces with underscores
for cert in $(ls USGOV-CA-*.pem)
do
    # get cert name (i.e Suject CN)
    cert_name=$(openssl x509 -in $cert -noout -text | egrep '^.*Subject:.*$' | sed -r 's/^.*CN = (.*)$/\1/g' | sed -r 's/ /_/g')
    mv $cert $cert_name.pem
    cp $cert_name.pem $cert_name.crt
done

# Ubuntu/Debian based
if [ -d /usr/share/ca-certificates ]
then
    # Copy certs to system cert store (directory of files)
    sudo cp *.crt /usr/share/ca-certificates/.
    # Update system ca certs
    sudo update-ca-certificates
fi

# Fedora/Red Hat based
if [ -d /usr/share/pki/ca-trust-source/anchors ]
then
    # Copy pem's to system trust store
    sudo cp *.pem /usr/share/pki/ca-trust-source/anchors/.
    # Update system ca certs
    sudo update-ca-trust
fi

# Import certs into Browser cert stores
for cert in $(ls *.crt)
do
    # get cert name (i.e Suject CN)
    cert_name=$(openssl x509 -in $cert -noout -text | egrep '^.*Subject:.*$' | sed -r 's/^.*CN = (.*)$/\1/g' | sed -r 's/ /_/g')
    # Import into Chromium based browsers cert store
    echo "add $cert_name to shared nss db"
    [ -d $HOME/.pki/nssdb ] && certutil -A -n $cert_name -t "CT,C,C" -d sql:$HOME/.pki/nssdb -i $cert
    [ -d $HOME/snap/chromium ] && certutil -A -n $cert_name -t "CT,C,C" -d sql:$HOME/snap/chromium/current/.pki/nssdb -i $cert
    # Import into Firefox browser cert store
    echo "add $cert_name to firefox"
    [ -d $HOME/.mozilla/firefox ] && certutil -A -n $cert_name -t "CT,C,C" -d $HOME/.mozilla/firefox/*.default-release -i $cert
    if [ -d $HOME/.mozilla/firefox ]
    then
        for dir in $(ls -d $HOME/.mozilla/firefox/*.default*)
        do
            certutil -A -n $cert_name -t "CT,C,C" -d $dir -i $cert
        done
    fi
    if [ -d $HOME/snap/firefox ]
    then
        for dir in $(ls -d $HOME/snap/firefox/common/.mozilla/firefox/*.default*)
        do
            certutil -A -n $cert_name -t "CT,C,C" -d $dir -i $cert
        done
    fi
done
popd

# Clean-up
popd
rm -rf dod-certs certificates_pkcs7_DoD.zip
