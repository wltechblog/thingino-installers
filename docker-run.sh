#!/usr/bin/env bash

case "$1" in
    "")
        echo "Usage: $0 <command>"
        echo "Command can be one of [up build enter down cleanup refresh]"
        echo "Refresh will attempt to destroy the current container and rebuild it, and enter it."
        exit 1
        ;;
    "up")
        docker-compose up -d --build && docker container exec -it thingino-image-builder-dev bash
        ;;
    "build")
        docker-compose build
        ;;
    "enter")
        docker container exec -it thingino-image-builder-dev bash
        ;;
    "down")
        docker-compose down
        ;;
    "cleanup")
        docker-compose down 2>/dev/null
        docker rmi thingino-installers-thingino-image-builder-dev
        ;;
    "refresh")
        docker-compose down 2>/dev/null
        docker rmi thingino-installers-thingino-image-builder-dev
        docker-compose up -d --build && docker container exec -it thingino-image-builder-dev bash
        ;;
    *)
        echo "Usage: $0 <command>"
        echo "Command can be one of [up build enter down refresh]"
        echo "Refresh will attempt to destroy the current container and rebuild it, and enter it."
        exit 1
        ;;
esac
