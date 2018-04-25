#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

function install_dependencies() {
	echo "Installing dependencies"
	apt update
	apt install -y git libnl-3-dev libnl-genl-3-dev pkg-config libssl-dev net-tools git sysfsutils python-scapy python-pip aircrack-ng
	pip install pycryptodomex
}

function clone_repo() {
	echo "Cloning repository"
	rm -rf ./krackattacks-scripts/
	git clone https://github.com/vanhoefm/krackattacks-scripts.git
}

function build_hostapd() {
	echo "Building hostapd"
	cd ./krackattacks-scripts/hostapd/
	cp defconfig .config
	make -j 2
	cd ../../
}

function disable_hardware_crypto() {
	echo "Disabling hardware crypto"
	./krackattacks-scripts/krackattack/disable-hwcrypto.sh
}

function configure_hostapd() {	
	echo "Configuring hostapd.conf"
	echo "=========================================="
	interfaces=($(ifconfig | awk '/w/{print$1}'))
	
	#Exit if no wireless interface
	if (( ${#interfaces[@]} <= 0 ))
	then
		echo "No wireless interface, connect a wifi device and try again!"
		exit
	fi
	
	for index in "${!interfaces[@]}"
	do
		echo "$index : ${interfaces[$index]}"
	done
	echo "Choose an interface to host a hotspot : "
	read input
	echo "=========================================="
	selected_interface="${interfaces[$input]}"
	echo "Modifying hostapd.conf"
	sed -i "s/^interface=\w*/interface=$selected_interface/" ./krackattacks-scripts/hostapd/hostapd.conf
	echo "Done!"
}

function reset_interfaces() {
	echo "Resetting all interfaces"
	interfaces=($(ifconfig | awk '/w/{print$1}'))
    for interface in "${interfaces[@]}"
    do
        echo "Resetting interface: $interface"
        sudo ifconfig $interface down
        sudo iwconfig $interface mode managed
        sudo ifconfig $interface up
    done
}

if [[ $# -eq 1 && $1 = "-i" ]]
then
	install_dependencies
	clone_repo
	disable_hardware_crypto
	build_hostapd
fi

if [[ $# -eq 1 && ( $1 = "-c" || $1 = "-i" ) ]]
then
	configure_hostapd
fi

reset_interfaces
echo "Killing network services and unblocking wifi in order to run test"
service networking stop
service network-manager stop
rfkill unblock wifi

echo "Running exploit, join testnetwork:abcdefgh. Press Ctrl+C to stop attack"
sudo ./krackattacks-scripts/krackattack/krack-test-client.py

echo "Remove monitor interface"
int=$(cat ./krackattacks-scripts/hostapd/hostapd.conf | grep -o "^interface=.*" | sed -n 's/^interface=//p')
iw ${int}mon del

echo "Restarting back your network services"
rfkill unblock wifi
service networking restart
service network-manager start
reset_interfaces
