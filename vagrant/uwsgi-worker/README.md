# Test uwsgi + apache locally

# Setup

Install vagrant (vagrant is a wrapper around virtualbox)

```
git clone <this repo>
cd <this repo>
vagrant up
vagrant ssh # go into machine/vm
```

# Connect
vagrant ssh

## Look around
```
systemctl status uwsgi.service # status of uwsgi
```

## uwsgi logs
```
sudo -i
journalctl -f -u uwsgi.service
```

# Reset /destroy everything

```
./rebuild.sh
```
