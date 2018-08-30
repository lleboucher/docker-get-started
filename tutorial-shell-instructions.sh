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
# The Python app is serving the http://0.0.0.0:80 (as seen from the inside of the
# container) but the docker instruction maps the port 80 to the external port 4000,
# go to the URL http://localhost:4000

# see the containers which were created

docker container ls

# The output is typically:
# CONTAINER ID        IMAGE               COMMAND             CREATED
# 1fa4ab2cf395        friendlyhello       "python app.py"     28 seconds ago


# Share the image on a public repository
# Log into the repository
docker login

# Tag the image

# The notation for associating a local image with a repository on a registry 
# is username/repository:tag. The tag is optional, but recommended, since it
# is the mechanism that registries use to give Docker images a version. Give
# the repository and tag meaningful names for the context, such as 
# get-started:part2. This puts the image in the get-started repository and 
# tag it as part2.

# Now, put it all together to tag the image. Run docker tag image with your
# username, repository, and tag names so that the image uploads to your
# desired destination. The syntax of the command is:
#
# docker tag image username/repository:tag
# 
# For example:

docker tag friendlyhello tsouche/get-started:part2

# Publish the image:
# Upload your tagged image to the repository:

docker push username/repository:tag

# Pull and run the image from the remote repository
# From now on, you can use docker run and run your app on any machine with this command:

docker run -p 4000:80 username/repository:tag
