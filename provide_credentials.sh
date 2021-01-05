#!/bin/bash

# print the usage of this script
print_usage() {
  printf "\nUsage: provide_credentials.sh PATH_TO_BOARD_DIR WIFI_SSID WIFI_PASSWORD PATH_TO_SSH_PUBKEY\n"
  printf "\nSet all the requiredcredentials to conenct to your raspberrypi4.\n\n"
  echo -e "\tPATH_TO_BOARD_DIR: path to the board directoryfor this buildroot project"
  echo -e "\tWIFI_SSID: the name of your wifi network"
  echo -e "\tWIFI_PASSWORD: the password to connect to the network"
  echo -e "\tPATH TO SSH_PUBKEY: a ssh pubkey to put in the authorized_keys list\n"
  echo -e "Example:\n"
  echo -e "./provide_credentials.sh ./board testwifi testpassword /home/test/.ssh/id_rsa.pub"
}

# usage captures

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
	print_usage
	exit 0
fi
if [ $# -ne 4 ]; then
	print_usage
	exit 1
fi

board=`realpath $1`
ssid=$2
password=$3
pubkey=`realpath $4`

# input verification

if [ ! -d $board ]; then
	>&2 echo "error: $board does not exist"
	exit 1
elif [ ! -r $board ]; then
	>&2 echo "error: cannot read $board"
	exit 1
fi

if [ ! -f $pubkey ]; then
	>&2 echo "error: $pubkey does not exist"
	exit 1
elif [ ! -r $pubkey ]; then
	>&2 echo "error: cannot read $pubkey"
	exit 1
fi

# writing wifi info
wpainfo=`wpa_passphrase $ssid $password`
echo -e "ctrl_interface=/run/wpa_supplicant\nupdate_config=1" > $board/raspberrypi4/wpa_supplicant.conf
echo "$wpainfo" >> $board/raspberrypi4/wpa_supplicant.conf

# copying over ssh key
cp $pubkey $board/raspberrypi4/authorized_keys

echo "done!"
