read -p "What is the client IP? " client_ip
read -p "What is the server IP? " server_ip

echo
echo "* Installing EPEL..."
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

echo
echo "* Installing strongswan..."
yum install strongswan -y


echo
echo "* Deploy ipsec.conf..."

cat > /etc/strongswan/ipsec.conf<<EOF
config setup
	charondebug="all"
	uniqueids=yes
	strictcrlpolicy=no

conn %default
conn tunnel
	left=${client_ip}
	leftsubnet=10.1.0.0/16
	right=${server_ip}
	rightsubnet=11.1.0.0/16
	ike=aes256-sha2_256-modp1024!
	esp=aes256-sha2_256!
	keyingtries=0
	ikelifetime=1h
	lifetime=8h
	dpddelay=30
	dpdtimeout=120
	dpdaction=clear
	authby=secret
	keyexchange=ikev2
	auto=start
	type=tunnel
EOF

echo
echo "* Deploy ipsec.secret..."

cat >/etc/strongswan/ipsec.secrets<<EOF
${client_ip} ${server_ip} : PSK 'sharedsecret'
EOF


echo
echo "* Turn off firewall..."
systemctl stop firewalld
systemctl disable firewalld

echo
echo "* Start strongswan..."
systemctl start strongswan
systemctl enable strongswan

echo
echo "* Done!"
echo
echo "Check the status with:"
echo "   systemctl status strongswan"
echo
echo "Check the tunnel status with:"
echo
echo "   ip xfrm state"
