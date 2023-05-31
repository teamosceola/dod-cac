#!/bin/bash

######################################################################################################
# Summary:                                                                                           #
#   - Installs Microsoft Edge for Linux                                                              #
#                                                                                                    #
# *NOTE: Do NOT run script with 'sudo', run as regular user                                          #
######################################################################################################

if [ $(which dnf | echo $?) == "0" ]
then
    sudo dnf update --refresh -y
    sudo dnf install unzip nss-tools openssl curl -y
fi
if [ $(which rpm-ostree | echo $?) == "0" ]
then
    rpm-ostree install --apply-live --idempotent --allow-inactive openssl nss-tools unzip curl -y
fi

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.microsoft.Edge -y