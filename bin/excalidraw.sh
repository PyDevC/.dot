#!/usr/bin/env bash

podman run --rm -it -p 3000:80 excalidraw/excalidraw:latest &
~/personal/software/zen/zen "http://localhost:3000"
