echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -p tcp --dport 45670 -j DNAT --to-destination 104.250.34.206:808
iptables -t nat -A POSTROUTING -p tcp -d 104.250.34.206 --dport 808 -j MASQUERADE

