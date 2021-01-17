#!/bin/bash
docker build -f build/Dockerfile-base -t ghcr.io/pterodactyl/development/base build
docker build -f build/Dockerfile-panel -t ghcr.io/pterodactyl/development/panel build
docker build -f build/Dockerfile-wings -t ghcr.io/pterodactyl/development/wings build