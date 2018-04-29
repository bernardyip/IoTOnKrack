#!/bin/bash

function get_mac_addr_and_hs() {
	line=$3
	regex=$4
	mac_addr=$(echo "$line" | pcregrep -o1 "$regex")
	hs=$(echo "$line" | pcregrep -o2 "$regex")
	eval "$1='${mac_addr}'"
	eval "$2='${hs}'"
}

function get_mac_addr() {
	line=$2
	regex=$3
	mac_addr=$(echo "$line" | pcregrep -o1 "$regex")
	eval "$1='${mac_addr}'"
}

function strlen() {
	str=$1
	return ${#str}
}

function process_line() {
	line=$1
	result=""
	
	timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"
	mac_addr=""
	hs=""
	get_mac_addr_and_hs mac_addr hs "$line" '\[.*\] .*m([a-f0-9:]*): Client reinstalls the group key in the (.*) handshake \(this is bad\).'
	if [[ ${#mac_addr} -gt 0 ]]; then
		filename=${mac_addr//:/-}
		echo $filename
		echo "${timestamp} ${mac_addr} reinstalls the group key in the 4-way handshake." >> "vuln-clients/$filename"
	fi

	mac_addr=""
	hs=""
	get_mac_addr_and_hs mac_addr hs "$line" '\[.*\] .*m([a-f0-9:]*): Client always installs the group key in the (.*) handshake with a zero replay counter \(this is bad\).'
	if [[ ${#mac_addr} -gt 0 ]]; then
		filename=${mac_addr//:/-}
		echo $filename
		echo "${timestamp} ${mac_addr} always installs the group key in the ${hs} handshake with a zero replay counter." >> "vuln-clients/$filename"
	fi

	mac_addr=""
	get_mac_addr mac_addr "$line" '\[.*\] .*m([a-f0-9:]*): Client accepts replayed broadcast frames \(this is bad\).'
	if [[ ${#mac_addr} -gt 0 ]]; then
		filename=${mac_addr//:/-}
		echo $filename
		echo "${timestamp} ${mac_addr} accepts replayed broadcast frames." >> "vuln-clients/$filename"
	fi

	mac_addr=""
	get_mac_addr mac_addr "$line" '\[.*\] .*m([a-f0-9:]*): IV reuse detected (.*)\. Client reinstalls the pairwise key in the 4-way handshake \(this is bad\)'
	if [[ ${#mac_addr} -gt 0 ]]; then
		filename=${mac_addr//:/-}
		echo $filename
		echo "${timestamp} ${mac_addr} reinstalls the pairwise key in the 4-way handshake." >> "vuln-clients/$filename"
	fi
}

#mac_addr=""
#get_mac_addr mac_addr "[14:39:19] 6c:8f:b5:fc:4f:2c: Client reinstalls the group key in the 4-way handshake (this is bad)." '\[.*\] (.*): Client reinstalls the group key in the 4-way handshake \(this is bad\).'
#echo $mac_addr

#process_line "[14:39:19] 6c:8f:b5:fc:4f:2c: Client reinstalls the group key in the 4-way handshake (this is bad)."

mkdir "vuln-clients/"
stdbuf -oL tail -f krackattack.log | {
	while IFS= read -r line
	do
		process_line "$line"
	done
}
