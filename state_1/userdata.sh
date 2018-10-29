#!/bin/bash
cd /tmp/
wget https://github.com/facevedom/hello-from/archive/v1.0.zip
unzip v1.0.zip
cd hello-from-1.0
pip install -r requeriments.txt
FLASK_APP=hello_from.py /usr/local/bin/flask run --host=0.0.0.0
