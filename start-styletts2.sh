#!/bin/bash

cd /root/StyleTTS2
source /root/StyleTTS2/env/bin/activate
gunicorn -b 0.0.0.0:5555 'main:app'
deactivate