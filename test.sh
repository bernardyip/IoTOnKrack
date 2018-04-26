#!/bin/bash

line="[14:39:19] 6c:8f:b5:fc:4f:2c: Client reinstalls the group key in the 4-way handshake (this is bad)."

if [[ $line =~ "\[.*\] (.*): Client reinstalls the group key in the 4-way handshake \(this is bad\)." ]]; then
	mac_addr="${BASH_REMATCH[1]}"
	result="${mac_addr} reinstalls the group key in the 4-way handshake."
	 
	echo "${result}"
else
	echo "false"
fi


echo "[14:39:19] 6c:8f:b5:fc:4f:2c: Client always installs the group key in the %s handshake with a zero replay counter (this is bad)." | pcregrep -o1 "\[.*\] (.*): Client always installs the group key in the (.*) handshake with a zero replay counter \(this is bad\)."




log(WARNING, ("%s: IV reuse detected (IV=%d, seq=%d). " +
	"Client reinstalls the pairwise key in the 4-way handshake (this is bad)") % (self.mac, iv, seq))

	#if self.options.gtkinit:
	#	log(WARNING, "%s: Client always installs the group key in the %s handshake with a zero replay counter (this is bad)." % (self.mac, hstype))
	#else:
	#	log(WARNING, "%s: Client reinstalls the group key in the %s handshake (this is bad)." % (self.mac, hstype))
	#log(WARNING, "                   Or client accepts replayed broadcast frames (see --replay-broadcast).")
if self.options.variant == TestOptions.ReplayBroadcast:
	log(WARNING, "%s: Client accepts replayed broadcast frames (this is bad)." % self.mac)
	log(WARNING, "                   Fix this before testing for group key (re)installations!")

