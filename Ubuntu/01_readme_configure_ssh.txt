sudo apt install net-tools
sudo apt install openssh-server
sudo vi /etc/ssh/sshd_config
==================
...
Port 10001
...
==================
sudo vi /etc/hosts.allow
==================
...
sshd: 192.168.
...
==================
sudo vi /etc/hosts.deny
==================
...
sshd: ALL
...
==================

sudo systemctl restart sshd

sudo ufw allow from 192.168.0.0/16 to any port 10001
sudo ufw allow from 192.168.200.167 to any port 10001
sudo ufw enable
sudo ufw reload
sudo ufw status
