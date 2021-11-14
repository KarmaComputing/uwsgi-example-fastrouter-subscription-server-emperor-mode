#!/usr/bin/env bash

apt-get update
apt-get install -y apache2 python3.8 python3.8-venv python3.8-dev build-essential libpcre3 libpcre3-dev

# uwsgi config
mkdir -p /etc/uwsgi/vassals/app1
mv /tmp/etc-emperor.ini /etc/uwsgi/emperor.ini

# uwsgi systemd
mv /tmp/systemd-uwsgi.service /etc/systemd/system/uwsgi.service

# uwsgi test site
mv /tmp/app.py /etc/uwsgi/vassals/app1/app.py 
mv /tmp/config.ini /etc/uwsgi/vassals/app1/config.ini

rm -rf /root/venv/
cd /root
python3.8 -m venv venv
. venv/bin/activate
pip install wheel
pip install --no-cache-dir uWSGI==2.0.20

mv /root/venv/bin/uwsgi /usr/local/bin

# Start
systemctl start uwsgi.service
