CentOS-7-x86_64-DVD-2009.iso

KEYBOARD LAYOUT
	Korean (101/104 key compatable)
SOFTWARE SELECTION
	Server with GUI
NETWORK & HOST NAME
	Ethernet (enp0s3) ON
	
root/********
nova/********
Make this user administrator CHECK

sudo firewall-cmd --permanent --zone=public --add-port=22/tcp
sudo firewall-cmd --reload

Network: NAT: port forwarding: SSH,,22,,22

Putty.exe: 192.168.56.1 nova/********
