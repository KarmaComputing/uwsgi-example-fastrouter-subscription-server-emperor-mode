# uwsgi fastrouter with subscription server and emperor example

- fastrouter - routing (speaks **uwsgi** protocol, not http (so you need `mod_proxy_uwsgi`))
- subscription server - so that apps can accounce themselves to 
- emperor - tell uwsgi to scan a directory of config files for each uwsgi-managed app (each app has one config file)

minimal viable run example of uwsgi fastrouter with
subscription server. 

## Setup 

```
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt

# setup vassal app
cd ./vassals/app1 # do the same for app2
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
cd ../
```

Start the fast router with subscription server, which looks in the 'vassals' directory for
apps to start.
```
./run.sh
```

Start an instance subscribing to the subscription server
on a random port (so you don't need to manually assign ports). [Read](https://uwsgi-docs.readthedocs.io/en/latest/Fastrouter.html#way-4-fastrouter-subscription-server)


## Example apache config
```
<VirtualHost *:80>
	ServerName example.com
	ServerAlias *.example.com

	LogLevel debug

	ProxyPass / uwsgi://127.0.0.1:3017/

	ErrorLog ${APACHE_LOG_DIR}/uwsgi-fast-router.error.log
	CustomLog ${APACHE_LOG_DIR}/uwsgi-fast-router.log combined

</VirtualHost>
# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```

### Curl the app

```
time curl -v http://example.com

(base) (main)$ time curl -v http://example.com
*   Trying 127.0.0.1:80...
* TCP_NODELAY set
* Connected to example.com (127.0.0.1) port 80 (#0)
> GET / HTTP/1.1
> Host: example.com
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Date: Sat, 13 Nov 2021 13:02:48 GMT
< Server: Apache/2.4.41 (Ubuntu)
< Content-Type: text/html; charset=utf-8
< Content-Length: 11
< Vary: Accept-Encoding
< 
* Connection #0 to host example.com left intact
hello world
real	0m0.017s
user	0m0.008s
sys	0m0.008s
```

# Smoke test

1. Edit your /etc/hosts file to have
   127.0.0.1 example.com
   127.0.0.1 app2.example.com
   # app3 etc..
2. Configure apache
3. Start uwsgi master (run.sh)
3. curl your app(s)

```
time curl -v http://example.com.com
time curl -v http://app2.example.com # etc
```

## Add a seccond / third / n worker nodes

"Worker node"? == A server which *only* has uwsgi managed 
apps, it does **not** run a subscription server or fastrouter (there is only one of these).

You can add as many additional servers as desired, and
they can automatically subscribe to the subscription server
so that the fastrouter knows to route to them.

The apache web server (proxying to fastrouter + subscription server) is the SPOF in this architecture (unless using somthing like CARP/VRRP), however it does have the operational benefit of being able to turn off / add/remove nodes at any point (e.g. for upgrade/patching).


`run.sh` on a worker node:
```
#!/bin/bash

set -x

uwsgi --emperor ./vassals/*/*.ini
```

With each app running within a `vassals` subdirectory.
Note: Vassals can (and do in this repo) run on the subscription server node too.

Example worker node directory layout:
```
~# tree vassals/
vassals/
└── app1
    ├── app.py
    └── config.ini
```

Contents of vassals/app1/app.py
```
def application(env, start_response):
    """
    A miniman WSGI application
    """

    http_status = '200 OK'
    response_headers = [('Content-Type', 'text/html')]
    response_text = b"Hello from app1\n"

    start_response(http_status, response_headers)
    return [response_text]
```

Contents of vassals/app1/config.ini:
```
[uwsgi]
strict = true

# See: https://uwsgi-docs.readthedocs.io/en/latest/Fastrouter.html#way-4-fastrouter-subscription-server 
socket = :3031

# Announce this app to the subscription server (so that
# fastrouter can route to this app)
subscribe-to = 10.0.2.2:7000:example.com

# Activate the virtual environment for this app
#virtualenv = %d/venv

# Tell uwsgi where the wsgi app is
wsgi-file = %d/app.py

# Set the current working direcotry for the app
chdir = %d
```



## Debugging

```
uwsgi --socket :0 --subscribe-to 127.0.0.1:7000:example.com \
  --virtualenv /home/chris/Documents/programming/python/uwsgi/fastrouter/vassals/venv \
  --wsgi-file /home/chris/Documents/programming/python/uwsgi/fastrouter/vassals/app.wsgi \
  --chdir /home/chris/Documents/programming/python/uwsgi/fastrouter/vassals
```
