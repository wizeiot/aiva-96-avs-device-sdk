#!/usr/bin/env bash

#
# Get Swap Memory Size, if it's zero we will create own 384MB a temp swap file
#
create_swapfile()
{
  SWAPSIZE=`free | awk '/Swap/ { printf "%d", $2/1024 }'`
  while [[ "$SWAPSIZE" -lt "511" ]]; do
    echo "=============================================================="
    echo "Create a temporary SWAP file. It will disappear when reboot."
    echo "** Please consier to add a permanent SWAP file/parition.    **"
    echo "=============================================================="
    sudo modprobe zram num_devices=1
    sudo -i bash -c '$(echo $((512 * 1024 * 1024)) > /sys/block/zram0/disksize)'
    sudo mkswap /dev/zram0
    sudo swapon -p 5 /dev/zram0
    SWAPSIZE=`free | awk '/Swap/ { printf "%d", $2/1024}'`
  done
  free
}

# Create temporary swpafile (512 MiB) 
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
