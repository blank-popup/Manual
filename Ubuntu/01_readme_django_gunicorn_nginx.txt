dave@dave-VirtualBox:~$ wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
dave@dave-VirtualBox:~$ bash Miniforge3-Linux-x86_64.sh
dave@dave-VirtualBox:~$ source ~/.bashrc
(base) dave@dave-VirtualBox:~$ conda config --set auto_activate_base false
(base) dave@dave-VirtualBox:~$ exit

dave@dave-VirtualBox:~$ conda activate
(base) dave@dave-VirtualBox:~$ conda search python
(base) dave@dave-VirtualBox:~$ conda create -n jango python=3.10

(base) dave@dave-VirtualBox:~$ conda activate jango
(jango) dave@dave-VirtualBox:~$ conda install -c conda-forge django djangorestframework django-cors-headers
(jango) dave@dave-VirtualBox:~$ mkdir WorkSpace
(jango) dave@dave-VirtualBox:~$ cd WorkSpace/
(jango) dave@dave-VirtualBox:~/WorkSpace$ django-admin startproject mmserver
(jango) dave@dave-VirtualBox:~/WorkSpace$ cd mmserver/
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ vi mmserver/settings.py
------------------
...
ALLOWED_HOSTS = [] -> ALLOWED_HOSTS = ['*']
...
------------------
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ sudo ufw allow 10004
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ python manage.py runserver 0:10004
CHECK: connecting 192.168.200.107:10004 at web browser

(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ conda install -c conda-forge gunicorn
EXPLAIN: gunicorn --bind 0.0.0.0:10004 <directory name which wsgi.py exist>.wsgi:application
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ ls
db.sqlite3  manage.py  mmserver
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ ls mmserver/
asgi.py  __init__.py  __pycache__  settings.py  urls.py  wsgi.py
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ gunicorn --bind 0.0.0.0:10004 mmserver.wsgi:application
CHECK: connecting 192.168.200.107:10004 at web browser

(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ sudo vi /etc/systemd/system/gunicorn.socket
------------------
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target

------------------
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ sudo vi /etc/systemd/system/gunicorn.service
------------------
[Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target

[Service]
User=dave
Group=www-data
WorkingDirectory=/home/dave/WorkSpace/mmserver
ExecStart=/home/dave/miniforge3/envs/jango/bin/gunicorn \
        --access-logfile access.log \
        --error-logfile error.log \
        --workers 3 \
        --bind unix:/run/gunicorn.sock \
        mmserver.wsgi:application

[Install]
WantedBy=multi-user.target

------------------
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ sudo systemctl start gunicorn.socket
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ sudo systemctl status gunicorn.socket
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ file /run/gunicorn.sock
/run/gunicorn.sock: socket

(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ sudo apt install nginx
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ sudo vi /etc/nginx/conf.d/mmserver.conf
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
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ sudo systemctl restart gunicorn.socket
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ sudo systemctl restart gunicorn
(jango) dave@dave-VirtualBox:~/WorkSpace/mmserver$ sudo systemctl restart nginx
CHECK: connecting 192.168.200.107:10004 at web browser


