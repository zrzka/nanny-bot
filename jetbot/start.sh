#!/usr/bin/env bash

echo "Starting nvargus-daemon..."
nvargus-daemon &

if ! [ -d /data/notebooks ]; then
  echo "Provisioning Jupyter notebooks..."
  cp -r /usr/src/app/jetbot/notebooks /data
fi

echo "Starting Jupyter..."
cd /data/notebooks
jupyter notebook --port=80 --no-browser --ip=0.0.0.0 --allow-root --config=/usr/src/app/jupyter_notebook_config.json
