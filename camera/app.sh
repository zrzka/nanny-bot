#!/usr/bin/env bash

ffserver -f /app/ffserver.conf &
ffmpeg -f video4linux2 -r 1 -i /dev/video0 http://localhost:3000/camera.ffm
