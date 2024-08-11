#!/bin/bash

cd /root/StyleTTS2
mkdir -p /workspace/reference_voices
source /root/StyleTTS2/env/bin/activate
gunicorn -b 0.0.0.0:5555 'main:app'
deactivate