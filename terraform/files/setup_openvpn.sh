#!/bin/bash
### Install software ###
sudo apt-get update -y
sudo apt-get install curl -y

### Install OpenVPN server ###
curl https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh --output /tmp/openvpn-install.sh
chmod +x /tmp/openvpn-install.sh
echo 'start' > /tmp/install.txt
sudo AUTO_INSTALL=y /tmp/openvpn-install.sh
sudo systemctl enable openvpn@server.service
# Allow mulltiple users to use the same OVPN config
echo 'duplicate-cn' | sudo tee -a /etc/openvpn/server.conf
# Set OpenVPN to split tunnel
sed -i '/redirect-gateway def1/d' /etc/openvpn/server.conf
# Restart
sudo systemctl restart openvpn@server.service
echo 'done' >> /tmp/install.txt