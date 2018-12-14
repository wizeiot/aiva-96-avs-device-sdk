#!/usr/bin/env bash

#
# Get Swap Memory Size, if it's zero we will create own 384MB a temp swap file
#
create_swapfile()
{
  SWAPSIZE=`free | awk '/Swap/ { printf "%d", $2/1024 }'`
  while [[ "$SWAPSIZE" -lt "384" ]]; do
    echo "=============================================================="
    echo "Create a temporary SWAP file. It will disappear when reboot."
    echo "** Please consier to add a performanant SWAP file/parition. **"
    echo "=============================================================="
    dd if=/dev/zero of=/tmp/swapfile.swp bs=1024 count=393224 status=progress
    chmod 600 /tmp/swapfile.swp
    sudo mkswap /tmp/swapfile.swp
    sudo swapon /tmp/swapfile.swp
   #sudo swapoff /tmp/swapfile.swp # /var/tmp is remained when reboot
    SWAPSIZE=`free | awk '/Swap/ { printf "%d", $2/1024}'`
  done
  free
}

# Create temporary swpafile (384 MiB) 
create_swapfile

# Download necessary files prefetch from avs-device-sdk
#wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/pi.sh
#wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/setup.sh
wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/genConfig.sh

echo "=============================================================="
echo "            AiVA-96 AVS Device SDK Installation"
echo "=============================================================="

Origin=$(pwd)
Credentials="config.json"
Credentials_Loc=$Origin/$Credentials
if [[ ! -f "$Credentials_Loc" ]]; then
    echo " ERROR - 'config.json' file not found."
    echo " Place your 'config.json' file to $Origin"
    echo " Ex) 'scp config.json linaro@ip_address:$Origin'"
    trap - ERR
    exit -1
fi

source ./setup.sh $Credentials
