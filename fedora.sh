#!/bin/bash

######################################################################################################
# Summary:                                                                                           #
#   - Installs Microsoft Edge for Linux                                                              #
#                                                                                                    #
# *NOTE: Do NOT run script with 'sudo', run as regular user                                          #
######################################################################################################

sudo dnf update --refresh -y
sudo dnf install dnf-plugins-core -y
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge -y
sudo dnf update --refresh -y
sudo dnf install microsoft-edge-stable -y
