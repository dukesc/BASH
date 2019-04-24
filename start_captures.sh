#!/bin/sh

# Fix MTU Issue for bond1
ifconfig bond1 mtu 4096
grep "Interface" /proc/net/bonding/bond1|awk '{print "ifconfig " $3 " mtu 4096"}' > /tmp/t_mtu;. /tmp/t_mtu;rm -f /tmp/t_mtu

# Uncomment for number of ACs

/wireshark_logs/scripts/start_ac_capture.sh 1
/wireshark_logs/scripts/start_ac_capture.sh 2
/wireshark_logs/scripts/start_ac_capture.sh 3
/wireshark_logs/scripts/start_ac_capture.sh 4
/wireshark_logs/scripts/start_ac_capture.sh 5
/wireshark_logs/scripts/start_ac_capture.sh 6
/wireshark_logs/scripts/start_ac_capture.sh 7
/wireshark_logs/scripts/start_ac_capture.sh 8 
/wireshark_logs/scripts/start_ac_capture.sh 9
/wireshark_logs/scripts/start_ac_capture.sh 10
