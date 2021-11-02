# Docker - useful commands

## General

- `$ docker ps` shows which containers are running
- `$ docker-compose up redis` starts up redis (or substitute another service) in isolation to test it's working

## Reset

- `$ docker-compose down --remove-orphans`
- `$ docker rm -f $(docker ps -a -q)`
- `$ docker volume rm $(docker volume ls -q)`
- Confirm no containers are running with `$ docker ps`
- Restart the container image with `$ script/server`
