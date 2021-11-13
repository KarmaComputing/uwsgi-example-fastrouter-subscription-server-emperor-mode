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
