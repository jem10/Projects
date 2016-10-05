#!/bin/bash

#Update ubuntu repositories  
apt-get update -y 

#Install Openvpn & Easy RSA 
apt-get install openvpn easy-rsa -y

# Unzip Openvpn server.conf into /etc/openvpn/
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf

# Set the Diffie Hellman parameter to 2048 and sets RSA key length when generating server and client keys
ed -s /etc/openvpn/server.conf <<< $',s/dh dh1024.pem/dh dh2048.pem/g\nw'

#Makes the VPN server the default gateway without losing the original default gateway (if you are disconnected), and adds a static route to the DHCP server.
ed -s /etc/openvpn/server.conf <<< $',s/;push "redirect-gateway def1 bypass-dhcp"/push "redirect-gateway def1 bypass-dhcp"/g\nw'

#Tells the server to push OpenDNS to connected clients for DNS resolution where possible
ed -s /etc/openvpn/server.conf <<< $',s/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 208.67.222.222"/g\nw'
ed -s /etc/openvpn/server.conf <<< $',s/;push "dhcp-option DNS 208.67.220.220"/push "dhcp-option DNS 208.67.220.220"/g\nw'

#Confines OpenVPN to the user nobody and group nogroup an unprivileged user with no default login capabilities, not root as default
ed -s /etc/openvpn/server.conf <<< $',s/;user nobody/user nobody/g\nw'
ed -s /etc/openvpn/server.conf <<< $',s/;group nogroup/group nogroup/g\nw'

#Sysctl setting, tells the server's kernel to forward traffic from client devices out to the Internet. 
echo 1 > /proc/sys/net/ipv4/ip_forward

#Permanent change
ed -s /etc/sysctl.conf <<< $',s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g\nw'

#Open port for 22 for SSH & 1194 for Openvpn
ufw allow ssh
ufw allow 1194/udp

#Accept forwarded pakets in the ufw forwarding policy
ed -s /etc/default/ufw <<< $',s/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g\nw'

ed -s /etc/ufw/before.rules <<<  $'10a\n # START OPENVPN RULES \n # NAT table rules \n *nat \n :POSTROUTING ACCEPT [0:0 ] \n # Allow traffic from OpenVPN client to eth0 \n -A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE \n COMMIT \n # END OPENVPN RULES \n\nw' 

ufw enable -y
echo "y"


#Creating the server and client certificates 
cp -r /usr/share/easy-rsa/ /etc/openvpn
mkdir /etc/openvpn/easy-rsa/keys

#Change export KEY_NAME="server"
ed -s /etc/openvpn/easy-rsa/vars <<< $',s/KEY_NAME="EasyRSA"/KEY_NAME="server"/g\nw'

#Creating the DH parameters
sudo openssl dhparam -out /etc/openvpn/dh2048.pem 2048

#Initialize the PKI (Public Key Infrastructure)
cd /etc/openvpn/easy-rsa
. ./vars

#Clear the working directory
./clean-all 

#Build Certificate authority 
./build-ca

#Generate a Certificate and Key for the Server
./build-key-server server
cp /etc/openvpn/easy-rsa/keys/{server.crt,server.key,ca.crt} /etc/openvpn
service openvpn start && service openvpn status
cd /etc/openvpn/easy-rsa

#Generate a Certificate and Key for the client
./build-key client1
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/easy-rsa/keys/client.ovpn
