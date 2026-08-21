#!/bin/bash
cd ${PROJECT_DIR}/navidrome || exit
docker compose build --pull caddy
