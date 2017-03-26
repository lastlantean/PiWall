#!/bin/bash
#This script is meant to be run on a fresh raspian image.

apt-get update
apt-get -y install hostapd isc-dhcp-server # install dhcp server and hostap
apt-get -y install iptables-persistent
apt-get -y install openvpn

cd /tmp
wget https://raw.githubusercontent.com/lastlantean/PiWall/master/configFiles/dhcpd.conf
wget https://raw.githubusercontent.com/lastlantean/PiWall/master/configFiles/isc-dhcp-server
wget https://raw.githubusercontent.com/lastlantean/PiWall/master/configFiles/hostapd.conf
wget https://raw.githubusercontent.com/lastlantean/PiWall/master/configFiles/sysctl.conf
wget https://raw.githubusercontent.com/lastlantean/PiWall/master/configFiles/wpa_supplicant.conf

mkdir network
cd network
wget https://raw.githubusercontent.com/lastlantean/PiWall/master/configFiles/network/interfaces
cd ..

mkdir default
cd default
wget https://raw.githubusercontent.com/lastlantean/PiWall/master/configFiles/default/hostapd
cd ..

mkdir init.d
cd init.d
wget https://raw.githubusercontent.com/lastlantean/PiWall/master/configFiles/init.d/hostapd
wget https://raw.githubusercontent.com/lastlantean/PiWall/master/configFiles/init.d/PiWall.sh
cd ..

cp dhcpd.conf /etc/dhcp/dhcpd.conf
cp isc-dhcp-server /etc/default/isc-dhcp-server
cp sysctl.conf /etc/sysctl.conf
cp wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

ifconfig wlan0 down

cp ./network/interfaces /etc/network/interfaces

ifconfig wlan0 192.168.42.1

cp hostapd.conf /etc/hostapd/hostapd.conf
cp ./default/hostapd /etc/default/hostapd
cp ./init.d/hostapd /etc/init.d/hostapd

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
iptables -A FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o tun0 -j ACCEPT

sh -c "iptables-save > /etc/iptables/rules.v4" # save

service hostapd start
service isc-dhcp-server start
update-rc.d hostapd enable
update-rc.d isc-dhcp-server enable

## Setup auto run of PiWall
cp ./init.d/PiWall.sh /etc/init.d/PiWall
chmod 777 /etc/init.d/PiWall
update-rc.d PiWall enable

echo "Setup is done. If there were no errors you can reboot the system. When it comes back up connect to the new AP and visit http://192.168.42.1:8080 in a browser"
