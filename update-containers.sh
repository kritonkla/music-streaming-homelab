#!/bin/bash

set -e

cd ${PROJECT_DIR}/navidrome || exit

CURRENT_VER=$(docker exec caddy caddy version 2>/dev/null | awk '{print $1}')
LATEST_VER=$(curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | grep "tag_name" | awk -F'"' '{print $4}')

echo "Current caddy version: $CURRENT_VER"

if [ -z "$LATEST_VER" ]; then
    echo "Failed to Fetch latest Caddy version from Github"
    exit 1
fi

echo "Latest caddy version: $LATEST_VER"

if [ "$CURRENT_VER" != "$LATEST_VER" ]; then
    read -p "New caddy version available. Do you want to rebuild? (Y/n)" yn
    case $yn in
    [yY]*|"" )
        LATEST_VER="$LATEST_VER" bash ./build-caddy.sh;;
    [nN]* )
        echo "skipping caddy build";;
    * )
        echo "answer y/n";;
    esac
else
    echo "Caddy is already up to date."
fi

docker compose pull --ignore-buildable
docker compose up -d
docker ps