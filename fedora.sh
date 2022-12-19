#!/bin/bash

######################################################################################################
# Summary:                                                                                           #
#   - Installs Microsoft Edge for Linux                                                              #
#                                                                                                    #
# *NOTE: Do NOT run script with 'sudo', run as regular user                                          #
######################################################################################################

sudo dnf update --refresh -y
sudo dnf install dnf-plugins-core unzip nss-tools openssl curl -y
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge -y
curl -sSL https://packages.microsoft.com/keys/microsoft.asc > ./microsoft.asc
sudo rpm --import ./microsoft.asc
rm ./microsoft.asc
sudo dnf update --refresh -y
sudo dnf install microsoft-edge-stable -y
