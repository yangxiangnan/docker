#!/usr/bin/env bash

# The following docker will be generated:
#  - flow.ci.backend: it includes api and control center
#  - flow.ci.agent:

# How to run flow.ci
# - backend: 'docker-compose up'
# - agent: docker run --network=host -e FLOW_ZOOKEEPER_HOST=127.0.0.1:2181 -e FLOW_AGENT_ZONE=default -e FLOW_AGENT_NAME={agent name} flow.ci.agent

FLOW_PLATFORM_PATH=../flow-platform
FLOW_WEB_PATH=../flow-web

cd $FLOW_PLATFORM_PATH
# mvn build artifact of each components
mvn clean install -DskipTests=true

cp ../docker/Dockerfile-git .
cp ../docker/docker/ .
docker build -t flow.ci.git:0.0.3 -f ./Dockerfile-git .

# build docker image for flow.ci backend
cp ../docker/Dockerfile-backend .
docker build -t flow.ci.backend:0.0.3 -f ./Dockerfile-backend .

# build docker compose service for flow.ci backend
docker-compose rm -f
docker-compose build


cp ../docker/Dockerfile-agent .
# build docker image for flow.ci agent
docker build -t flow.ci.agent:0.0.3 -f ./Dockerfile-agent .

# build web
cd $FLOW_WEB_PATH
FLOW_WEB_API=http://localhost:8080/flow-api   npm run  build

cp ../docker/Dockerfile-web .
cp ../docker/default.conf .
docker build -t flow.web:0.0.3 -f ./Dockerfile-web .
