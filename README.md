# uwsgi fastrouter with subscription server example

minimal viable run example of uwsgi fastrouter with
subscription server. 

## Setup 

```
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

Start the fast router with subscription server
```
./run
```

Start an instance subscribing to the subscription server
on a random port (so you don't need to manually assign ports). [Read](https://uwsgi-docs.readthedocs.io/en/latest/Fastrouter.html#way-4-fastrouter-subscription-server)

```
. venv/bin/activate
uwsgi --socket :0 --subscribe-to 127.0.0.1:7000:example.com
```

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
