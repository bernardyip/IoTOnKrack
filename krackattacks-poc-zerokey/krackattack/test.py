from scapy.all import *

def get_tlv_value(p, type):
	if not Dot11Elt in p: return None
	el = p[Dot11Elt]
	while isinstance(el, Dot11Elt):
		if el.ID == type:
			return el.info
		el = el.payload
	return None

def cb(pkt): 
	if get_tlv_value(pkt, 0) == "ProDNPhotog":
		print "hi"

sniff(iface="wlp4s0", prn=cb)

