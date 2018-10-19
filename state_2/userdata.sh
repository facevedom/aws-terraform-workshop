#!/bin/bash
cd /tmp/
git clone https://github.com/facevedom/hello-from.git
pip install -r requirements.txt
FLASK_APP=hello_from.py flask run



