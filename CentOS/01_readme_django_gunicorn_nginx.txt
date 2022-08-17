Network: Bridge Adapter
[nova@localhost ~]$ ifconfig
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.200.177  netmask 255.255.255.0  broadcast 192.168.200.255
        inet6 fe80::54a5:4983:eaba:41e3  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:0a:55:fd  txqueuelen 1000  (Ethernet)
...

Last login: Thu Jul 28 12:01:30 2022 from gateway
[nova@localhost ~]$ sudo timedatectl set-timezone Asia/Seoul
[nova@localhost ~]$ mkdir WorkSpace
[nova@localhost ~]$ cd WorkSpace/
[nova@localhost WorkSpace]$ wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
[nova@localhost WorkSpace]$ bash Miniforge3-Linux-x86_64.sh
[nova@localhost WorkSpace]$ source ~/.bashrc
(base) [nova@localhost WorkSpace]$ conda config --set auto_activate_base false
(base) [nova@localhost WorkSpace]$ exit

Last login: Thu Aug 11 10:13:48 2022 from 192.168.200.167
[nova@localhost ~]$ conda activate
(base) [nova@localhost ~]$ conda search python
(base) [nova@localhost ~]$ conda create -n jango python=3.10
(base) [nova@localhost ~]$ conda activate jango
(jango) [nova@localhost ~]$ conda install -c conda-forge django djangorestframework django-cors-headers
(jango) [nova@localhost ~]$ cd WorkSpace/
(jango) [nova@localhost WorkSpace]$ django-admin startproject mmserver
(jango) [nova@localhost WorkSpace]$ cd mmserver/
(jango) [nova@localhost mmserver]$ sudo firewall-cmd --zone=public --permanent --add-port=10004/tcp
(jango) [nova@localhost mmserver]$ sudo firewall-cmd --reload
(jango) [nova@localhost mmserver]$ sudo firewall-cmd --zone=public --list-port
22/tcp 10004/tcp
(jango) [nova@localhost mmserver]$ vi mmserver/settings.py
------------------
...
ALLOWED_HOSTS = [] -> ALLOWED_HOSTS = ['*']
...
------------------
(jango) [nova@localhost mmserver]$ python manage.py runserver 0:10004
CHECK: connecting 192.168.200.177:10004 at web browser

(jango) [nova@localhost mmserver]$ conda install -c conda-forge gunicorn
EXPLAIN: gunicorn --bind 0.0.0.0:10004 <directory name which wsgi.py exist>.wsgi:application
(jango) [nova@localhost mmserver]$ ls
db.sqlite3  manage.py  mmserver
(jango) [nova@localhost mmserver]$ ls mmserver/
asgi.py  __init__.py  __pycache__  settings.py  urls.py  wsgi.py
(jango) [nova@localhost mmserver]$ gunicorn --bind 0.0.0.0:10004 mmserver.wsgi:application
CHECK: connecting 192.168.200.177:10004 at web browser

[nova@localhost ~]$ sudo vi /etc/systemd/system/gunicorn.socket
------------------
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target

------------------


[nova@localhost ~]$ sudo vi /etc/systemd/system/gunicorn.service
------------------
[Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target

[Service]
User=nova
Group=nova
WorkingDirectory=/home/nova/WorkSpace/mmserver
ExecStart=/home/nova/miniforge3/envs/jango/bin/gunicorn \
        --access-logfile access.log \
        --error-logfile error.log \
        --access-logfile - \
        --workers 3 \
        --bind unix:/run/gunicorn.sock \
        mmserver.wsgi:application

[Install]
WantedBy=multi-user.target

------------------


[nova@localhost ~]$ sudo vi /etc/yum.repos.d/nginx.repo
------------------
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1

------------------


[nova@localhost ~]$ sudo yum install nginx



[nova@localhost ~]$ sudo vi /etc//nginx/conf.d/mmserver.conf
------------------
server {
    listen 10004;
    server_name 192.168.200.177;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://mmserver;

    }
}

upstream mmserver {
    server unix:/run/gunicorn.sock;
}

------------------



sudo semanage permissive -a httpd_t

sudo systemctl start gunicorn.socket
sudo systemctl start gunicorn
sudo systemctl start nginx

sudo systemctl stop nginx
sudo systemctl stop gunicorn.socket
sudo systemctl stop gunicorn

sudo systemctl status gunicorn.socket
sudo systemctl status gunicorn
sudo systemctl status nginx


sudo vi /etc/systemd/system/gunicorn.socket
sudo vi /etc/systemd/system/gunicorn.service
sudo vi /etc//nginx/conf.d/mmserver.conf

