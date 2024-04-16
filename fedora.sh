#!/bin/bash

######################################################################################################
# Summary:                                                                                           #
#   - Installs Microsoft Edge for Linux                                                              #
#                                                                                                    #
# *NOTE: Do NOT run script with 'sudo', run as regular user                                          #
######################################################################################################

# Install needed tools
if [ $(which dnf | echo $?) == "0" ]
then
    sudo dnf update --refresh -y
    sudo dnf install unzip nss-tools openssl curl -y
fi
if [ $(which rpm-ostree | echo $?) == "0" ]
then
    rpm-ostree install --apply-live --idempotent --allow-inactive openssl nss-tools unzip curl -y
fi

# Enable p11-kit server as user service
systemctl --user enable p11-kit-server.service
systemctl --user start p11-kit-server.service

# Add Flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Microsoft Edge from Flathub
flatpak install flathub com.microsoft.Edge -y

# Override pkcs11 provider to make CAC work in Edge flatpak
flatpak override -u --filesystem=xdg-run/p11-kit/pkcs11 com.microsoft.Edge
