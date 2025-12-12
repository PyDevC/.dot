#!/usr/bin/env bash

container="$1"
app="$2"

podman start $container
podman exec $container $app
