#!/usr/bin/env bash


#
# Docker get started - Part 2
#

# build the docker image for the python app
#    -t = name the image
#    .  = path to the Dockerfile

docker build -t friendlyhello .

# see the images which were built or retrieved from the stores

docker image ls -a

# set the corresponding container and start the service
#    -p = port mapping rule : -p external_port:internal_port

docker run -p 4000:80 friendlyhello

# set the corresponding container and start the service in the background
#    -d = detached mode ( = execution in the background)

docker run -d -p 4000:80 friendlyhello

# To test the service, use a browser:
# The Python app is serving the http://0.0.0.0:80 (as seen from the inside of the container) but the docker instruction
# maps the port 80 to the external port 4000, go to the URL http://localhost:4000

# see the containers which were created

docker container ls

# The output is typically:
# CONTAINER ID        IMAGE               COMMAND             CREATED
# 1fa4ab2cf395        friendlyhello       "python app.py"     28 seconds ago

