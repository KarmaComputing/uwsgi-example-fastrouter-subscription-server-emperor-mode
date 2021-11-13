#!/bin/bash
uwsgi --socket :0 --subscribe-to 127.0.0.1:7000:example.com
