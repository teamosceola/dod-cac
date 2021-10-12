# dod-cac
Configure Browsers for DoD CAC Support

# Summary
- Installs Microsoft Edge for Linux
- Installs Smart Card tools for Linux
- Adds CAC (Smart Card) module support to Chromium based browsers (Chrome, Edge, Chromium, etc.)
- Adds CAC (Smart Card) module support to Firefox browser
- Downloads latest DoD Certificates from cyber.mil
- Extracts and converts DoD certs to usable format
- Imports all DoD Root and Intermediate CAs into Chromium based browsers
- Imports all DoD Root and Intermediate CAs into Firefox browser
- Imports all DoD Root and Intermediate CAs into base OS cert store

# Tested On
- Ubuntu 21.04

# How-To
>NOTE: Make sure all browser windows are closed before running
```
git clone https://github.com/teamosceola/dod-cac.git
cd dod-cac
./setup.sh
```