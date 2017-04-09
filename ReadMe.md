PiWall
============

Connecting to untrusted wifi access points can be dangerous. PiWall creates a personal WiFi access point that acts as a bridge between your devices and your VPN provider. This allows you to hide your traffic from the wifi provider you are connected to. It's meant to be used when traveling but can just as well be used at home.

**This project is under development and not ready for production use!**

## Install
1. Start with a clean install of raspbian
2. Connect the Raspberry pi to the Internet trough the Ethernet port. We will reconfigure the wifi so this can not be used.
3. Make sure you have pluged in a wifi dongel in the USB
4. Run wget https://raw.githubusercontent.com/lastlantean/PiWall/master/setup.sh;sudo chmod 777 setup.sh;sudo ./setup.sh
5. If there where no errors you can restart and connect to the PiWall AP.
6. Before you can use the device you need to set up openVPN to conenct to your provider.
6. Now open a browser and go to 192.168.42.1:8080 and do the configurations
