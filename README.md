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
- Fedora 35

# How-To

## Ubuntu
Install Microsoft Edge Browser, and configure for CAC support:
>NOTE: Make sure all browser windows are closed before running
```
git clone https://github.com/teamosceola/dod-cac.git
cd dod-cac
./ubuntu.sh
```
Launch the Microsoft Edge browser at least once to ensure that the nssdb database gets created, then run:
```
./dod-certs.sh
```

## Fedora
Install Microsoft Edge Browser:
```
git clone https://github.com/teamosceola/dod-cac.git
cd dod-cac
./fedora.sh
```
Launch the Microsoft Edge browser at least once to ensure that the nssdb database gets created, then run:
```
./dod-certs.sh
```

## Install DOD Root/Intermediate Certificate Authorities
Install the DOD root and intermediate CA certificates into both system trust store and browser trust stores
```
git clone https://github.com/teamosceola/dod-cac.git
cd dod-cac
./dod-certs.sh
```