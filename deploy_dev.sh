#!/bin/bash

docker login
docker build . -t yancouto/daissu-server:dev
docker push yancouto/daissu-server:dev
