#!/bin/bash
set -e
cd ${PROJECT_DIR}/navidrome || exit
echo "building caddy ${LATEST_VER:-$(curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | grep "tag_name" | awk -F'"' '{print $4}')}
docker compose build --pull caddy
