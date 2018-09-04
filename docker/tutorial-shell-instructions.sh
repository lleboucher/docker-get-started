#!/usr/bin/env bash

################################################################################
#
# Docker get started - Part 2 - Containers
#
################################################################################

# build the docker image for the python app
#    -t = name the image
#    .  = path to the Dockerfile

$ docker build -t friendlyhello .

# see the images which were built or retrieved from the stores

$ docker image ls -a

# set the corresponding container and start the service
#    -p = port mapping rule : -p external_port:internal_port

$ docker run -p 4000:80 friendlyhello

# set the corresponding container and start the service in the background
#    -d = detached mode ( = execution in the background)

$ docker run -d -p 4000:80 friendlyhello

# To test the service, use a browser:
# The Python app is serving the http://0.0.0.0:80 (as seen from the inside of
# the container) but the docker instruction maps the port 80 to the external 
# port 4000, go to the URL http://localhost:4000

# see the containers which were created

$ docker container ls

# The output is typically:
# CONTAINER ID        IMAGE               COMMAND             CREATED
# 1fa4ab2cf395        friendlyhello       "python app.py"     28 seconds ago


# Share the image on a public repository
# Log into the repository

$ docker login

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

$ docker tag friendlyhello tsouche/get-started:part2

# Publish the image:
# Upload your tagged image to the repository:

$ docker push username/repository:tag

# Pull and run the image from the remote repository
# From now on, you can use docker run and run your app on any machine with this 
# command:

$ docker run -p 4000:80 username/repository:tag


# REMINDER FOR PART 2

docker build -t friendlyhello . # Create image using this directory's Dockerfile
docker run -p 4000:80 friendlyhello # Run "friendlyname" mapping port 4000 to 80
docker run -d -p 4000:80 friendlyhello        # Same thing, but in detached mode
docker container ls                                # List all running containers
docker container ls -a             # List all containers, even those not running
docker container stop <hash>           # Gracefully stop the specified container
docker container kill <hash>         # Force shutdown of the specified container
docker container rm <hash>        # Remove specified container from this machine
docker container rm $(docker container ls -a -q)         # Remove all containers
docker image ls -a                             # List all images on this machine
docker image rm <image id>            # Remove specified image from this machine
docker image rm $(docker image ls -a -q)   # Remove all images from this machine
docker login             # Log in this CLI session using your Docker credentials
docker tag <image> username/repository:tag  # Tag <image> for upload to registry
docker push username/repository:tag            # Upload tagged image to registry
docker run username/repository:tag                   # Run image from a registry




################################################################################
#
# Docker get started - Part 3 - Services
#
################################################################################



# Your first docker-compose.yml file

# A docker-compose.yml file is a YAML file that defines how Docker containers 
# should behave in production. Here, we will use the docker-compose-part3.yml
# file which tells Docker to do the following:
#     - pull the image we uploaded in step 2 from the registry.
#     - run 5 instances of that image as a service called web, limiting each one
#       to use, at most, 10% of the CPU (across all cores), and 50MB of RAM.
#     - immediately restart containers if one fails.
#     - map port 4000 on the host to web’s port 80.
#     - instruct web’s containers to share port 80 via a load-balanced network 
#       called webnet. (Internally, the containers themselves publish to web’s 
#       port 80 at an ephemeral port.)
#     - define the webnet network with the default settings (which is a load-
#       balanced overlay network).
# 


# Run your new load-balanced app

# Before we can use the docker stack deploy command we first run:

$ docker swarm init

#     Note: We get into the meaning of that command in part 4. If you don’t run 
#           docker swarm init you get an error that “this node is not a swarm 
#           manager.”
# 
# Now let’s run it. You need to give your app a name. Here, it is set to 
# getstartedlab:

$ docker stack deploy -c docker-compose-part3.yml getstartedlab

# Our single service stack is running 5 container instances of our deployed 
# image on one host. Let’s investigate.
# Get the service ID for the one service in our application:

$ docker service ls

# Look for output for the web service, prepended with your app name. If you 
# named itthe same as shown in this example, the name is getstartedlab_web. The 
# service ID is listed as well, along with the number of replicas, image name, 
# and exposed ports.
# 
# A single container running in a service is called a task. Tasks are given 
# unique IDs that numerically increment, up to the number of replicas you 
# defined in docker-compose.yml. List the tasks for your service:

$ docker service ps getstartedlab_web

# Tasks also show up if you just list all the containers on your system, though 
# that is not filtered by service:

$ docker container ls -q

# Scale the app
# 
# You can scale the app by changing the replicas value in 
# docker-compose-part3.yml, saving the change, and re-running the "docker stack
# deploy" command:

$ docker stack deploy -c docker-compose-part3.yml getstartedlab

# Docker performs an in-place update, no need to tear the stack down first or 
# kill any containers.
# 
# Now, re-run docker container ls -q to see the deployed instances reconfigured.
# If you scaled up the replicas, more tasks, and hence, more containers, are 
# started.
# 
 
# Take the app down with docker stack rm:

$ docker stack rm getstartedlab

# Take down the swarm.

$ docker swarm leave --force

# It’s as easy as that to stand up and scale your app with Docker. You’ve taken 
# ahuge step towards learning how to run containers in production. Up next, you 
# learn how to run this app as a bonafide swarm on a cluster of Docker machines.
# 
#   Note: Compose files like this are used to define applications with Docker, 
#         and can be uploaded to cloud providers using Docker Cloud, or on any 
#         hardware or cloud provider you choose with Docker Enterprise Edition.



# REMINDER FOR PART 3:

docker stack ls                                            # List stacks or apps
docker stack deploy -c <composefile> <appname>  # Run the specified Compose file
docker service ls                 # List running services associated with an app
docker service ps <service>                  # List tasks associated with an app
docker inspect <task or container>                   # Inspect task or container
docker container ls -q                                      # List container IDs
docker stack rm <appname>                             # Tear down an application
docker swarm leave --force      # Take down a single node swarm from the manager




################################################################################
#
# Docker get started - Part 4 - Swarms
#
################################################################################



# In part 3, you took an app you wrote in part 2, and defined how it should run 
# in production by turning it into a service, scaling it up 5x in the process.
# Here in part 4, you deploy this application onto a cluster, running it on 
# multiple machines. Multi-container, multi-machine applications are made 
# possible by joining multiple machines into a “Dockerized” cluster called a 
# swarm.

# A swarm is a group of machines that are running Docker and joined into a 
# cluster. After that has happened, you continue to run the Docker commands 
# you’re used to, but now they are executed on a cluster by a swarm manager. The
# machines in a swarm can be physical or virtual. After joining a swarm, they 
# are referred to as nodes.

# Swarm managers can use several strategies to run containers, such as “emptiest 
# node” -- which fills the least utilized machines with containers. Or “global”, 
# which ensures that each machine gets exactly one instance of the specified 
# container. You instruct the swarm manager to use these strategies in the 
# Compose file, just like the one you have already been using.

# Swarm managers are the only machines in a swarm that can execute your 
# commands, or authorize other machines to join the swarm as workers. Workers 
# are just there to provide capacity and do not have the authority to tell any 
# other machine what it can and cannot do.

# Up until now, you have been using Docker in a single-host mode on your local 
# machine. But Docker also can be switched into swarm mode, and that’s what 
# enables the use of swarms. Enabling swarm mode instantly makes the current 
# machine a swarm manager. From then on, Docker runs the commands you execute on
# the swarm you’re managing, rather than just on the current machine.


# Set up your swarm

# A swarm is made up of multiple nodes, which can be either physical or virtual
# machines. The basic concept is simple enough: run docker swarm init to enable 
# swarm mode and make your current machine a swarm manager, then run docker 
# swarm join on other machines to have them join the swarm as workers. Choose a
# tab below to see how this plays out in various contexts. We use VMs to quickly
# create a two-machine cluster and turn it into a swarm.

# Create a cluster

# You need a hypervisor that can create virtual machines (VMs), so install 
# Oracle VirtualBox for your machine’s OS.

# Now, create a couple of VMs using docker-machine, using the VirtualBox driver:

$ docker-machine create --driver virtualbox myvm1
$ docker-machine create --driver virtualbox myvm2

# You now have two VMs created, named myvm1 and myvm2.

# Use this command to list the machines and get their IP addresses.

$ docker-machine ls
# NAME    ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
# myvm1   -        virtualbox   Running   tcp://192.168.99.100:2376           v17.06.2-ce
# myvm2   -        virtualbox   Running   tcp://192.168.99.101:2376           v17.06.2-ce


# Initialize the swarm and add nodes

# The first machine acts as the manager, which executes management commands and
# authenticates workers to join the swarm, and the second is a worker. You can 
# send commands to your VMs using docker-machine ssh. Instruct myvm1 to become a
# swarm manager with docker swarm init and look for output like this:

$ docker-machine ssh myvm1 "docker swarm init --advertise-addr <myvm1 ip>"
# Swarm initialized: current node <node ID> is now a manager.

# To add a worker to this swarm, run the following command and follow the 
# instructions:

$ docker swarm join --token <token> <myvm ip>:<port>

# As you can see, the response to docker swarm init contains a pre-configured 
# docker swarm join command for you to run on any nodes you want to add. Copy 
# this command, and send it to myvm2 via docker-machine ssh to have myvm2 join 
# your new swarm as a worker:

$ docker-machine ssh myvm2 "docker swarm join --token <token> <ip>:2377"

# This node joined a swarm as a worker.
# Congratulations, you have created your first swarm!

# Run docker node ls on the manager to view the nodes in this swarm:

$ docker-machine ssh myvm1 "docker node ls"
# ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
# brtu9urxwfd5j0zrmkubhpkbd     myvm2               Ready               Active
# rihwohkh3ph38fhillhhb84sk *   myvm1               Ready               Active              Leader


# Leaving a swarm

# If you want to start over, you can run docker swarm leave from each node.

# Deploy your app on the swarm cluster

# The hard part is over. Now you just repeat the process you used in part 3 to
# deploy on your new swarm. Just remember that only swarm managers like myvm1
# execute Docker commands; workers are just for capacity.

# Configure a docker-machine shell to the swarm manager

# So far, you’ve been wrapping Docker commands in docker-machine ssh to talk to
# the VMs. Another option is to run docker-machine env <machine> to get and run
# a command that configures your current shell to talk to the Docker daemon on
# the VM. This method works better for the next step because it allows you to
# use your local docker-compose.yml file to deploy the app “remotely” without
# having to copy it anywhere.

$ docker-machine env myvm1
# export DOCKER_TLS_VERIFY="1"
# export DOCKER_HOST="tcp://192.168.99.100:2376"
# export DOCKER_CERT_PATH="/Users/sam/.docker/machine/machines/myvm1"
# export DOCKER_MACHINE_NAME="myvm1"

# Either type "docker-machine env myvm1", then copy-paste and run the command 
# provided as the last line of the output to configure your shell to talk to 
# myvm1, the swarm manager, or use the "eval" shell command to do the job:

eval $(docker-machine env myvm1)

# Run docker-machine ls to verify that myvm1 is now the active machine, as 
# indicated by the asterisk next to it.

$ docker-machine ls
# NAME    ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
# myvm1   *        virtualbox   Running   tcp://192.168.99.100:2376           v17.06.2-ce
# myvm2   -        virtualbox   Running   tcp://192.168.99.101:2376           v17.06.2-ce

# Deploy the app on the swarm manager

# Now that you have myvm1, you can use its powers as a swarm manager to deploy 
# your app by using the same docker stack deploy command you used in part 3 to
# myvm1, and your local copy of docker-compose.yml.. This command may take a few
# seconds to complete and the deployment takes some time to be available. Use
# the docker service ps <service_name> command on a swarm manager to verify that
# all services have been redeployed.

# You are connected to myvm1 by means of the docker-machine shell configuration,
# and you still have access to the files on your local host. Make sure you are
# in the same directory as before, which includes the docker-compose.yml file
# you created in part 3.

# Just like before, run the following command to deploy the app on myvm1.

$ docker stack deploy -c docker-compose-part3.yml getstartedlab

# And that’s it, the app is deployed on a swarm cluster!
# 
#     Note: If your image is stored on a private registry instead of Docker Hub,
#           you need to be logged in using docker login <your-registry> and then
#           you need to add the --with-registry-auth flag to the above command.
#           For example:
 
$ docker login registry.example.com
 
$ docker stack deploy --with-registry-auth \
    -c docker-compose-part3.yml getstartedlab
 
#           This passes the login token from your local client to the swarm 
#           nodes where the service is deployed, using the encrypted WAL logs. 
#           With this information, the nodes are able to log into the registry
#           and pull the image.

# Now you can use the same docker commands you used in part 3. Only this time 
# notice that the services (and associated containers) have been distributed 
# between both myvm1 and myvm2.

$ docker stack ps getstartedlab
# ID            NAME                  IMAGE                     NODE   DESIRED STATE
# jq2g3qp8nzwx  getstartedlab_web.1   gordon/get-started:part2  myvm1  Running
# 88wgshobzoxl  getstartedlab_web.2   gordon/get-started:part2  myvm2  Running
# vbb1qbkb0o2z  getstartedlab_web.3   gordon/get-started:part2  myvm2  Running
# ghii74p9budx  getstartedlab_web.4   gordon/get-started:part2  myvm1  Running
# 0prmarhavs87  getstartedlab_web.5   gordon/get-started:part2  myvm2  Running


# Connecting to VMs with docker-machine env and docker-machine ssh

# To set your shell to talk to a different machine like myvm2, simply re-run 
# docker-machine env in the same or a different shell, then run the given 
# command to point to myvm2. This is always specific to the current shell. If 
# you change to an unconfigured shell or open a new one, you need to re-run the
# commands. Use docker-machine ls to list machines, see what state they are in,
# get IP addresses, and find out which one, if any, you are connected to. To 
# learn more, see the Docker Machine getting started topics.

# Alternatively, you can wrap Docker commands in the form of 
# docker-machine ssh <machine> "<command>", which logs directly into the VM but 
# doesn’t give you immediate access to files on your local host.

# You can use the following command to copy files across machines:
$ docker-machine scp <file> <machine>:~


# Accessing your cluster

# You can access your app from the IP address of either myvm1 or myvm2.

# The network you created is shared between them and load-balancing. Run 
# docker-machine ls to get your VMs’ IP addresses and visit either of them on a
# browser, hitting refresh (or just curl them).
# There are five possible container IDs all cycling by randomly, demonstrating 
# the load-balancing.

# The reason both IP addresses work is that nodes in a swarm participate in an 
# ingress routing mesh. This ensures that a service deployed at a certain port
# within your swarm always has that port reserved to itself, no matter what node
# is actually running the container.

# Having connectivity trouble?

# Keep in mind that to use the ingress network in the swarm, you need to have 
# the following ports open between the swarm nodes before you enable swarm mode:
#         Port 7946 TCP/UDP for container network discovery.
#         Port 4789 UDP for the container ingress network.

# Iterating and scaling your app

# From here you can do everything you learned about in parts 2 and 3.
#   - Scale the app by changing the docker-compose.yml file.
#   - Change the app behavior by editing code, then rebuild, and push the new 
#       image. (To do this, follow the same steps you took earlier to build the
#       app and publish the image).
# In either case, simply run docker stack deploy again to deploy these changes.

# You can join any machine, physical or virtual, to this swarm, using the same 
# docker swarm join command you used on myvm2, and capacity is added to your 
# cluster. Just run docker stack deploy afterwards, and your app can take 
# advantage of the new resources.


# Cleanup and reboot Stacks and swarms

# You can tear down the stack with docker stack rm. For example:

$ docker stack rm getstartedlab

# Keep the swarm or remove it?

# At some point later, you can remove this swarm if you want to with 
# docker-machine ssh myvm2 "docker swarm leave" on the worker and docker-machine
# ssh myvm1 "docker swarm leave --force" on the manager, but you need this swarm
# for part 5, so keep it around for now.

# Unsetting docker-machine shell variable settings

# You can unset the docker-machine environment variables in your current shell 
# with the given command:

$ eval $(docker-machine env -u)

# This disconnects the shell from docker-machine created virtual machines, and 
# allows you to continue working in the same shell, now using native docker 
# commands (for example, on Docker for Mac or Docker for Windows). To learn 
# more, see the Machine topic on unsetting environment variables.


# Restarting Docker machines

# If you shut down your local host, Docker machines stops running. You can check
# the status of machines by running docker-machine ls.

$ docker-machine ls
# NAME    ACTIVE   DRIVER       STATE     URL   SWARM   DOCKER    ERRORS
# myvm1   -        virtualbox   Stopped                 Unknown
# myvm2   -        virtualbox   Stopped                 Unknown

# To restart a machine that’s stopped, run:

$ docker-machine start <machine-name>

# For example:

$ docker-machine start myvm1
# Starting "myvm1"...
# (myvm1) Check network to re-create if needed...
# (myvm1) Waiting for an IP...
# Machine "myvm1" was started.
# Waiting for SSH to be available...
# Detecting the provisioner...
# Started machines may have new IP addresses. You may need to re-run the `docker-machine env` command.

$ docker-machine start myvm2
# Starting "myvm2"...
# (myvm2) Check network to re-create if needed...
# (myvm2) Waiting for an IP...
# Machine "myvm2" was started.
# Waiting for SSH to be available...
# Detecting the provisioner...
# Started machines may have new IP addresses. You may need to re-run the `docker-machine env` command.


# REMINDER FOR PART 4:

# In part 4 you learned what a swarm is, how nodes in swarms can be managers or
# workers, created a swarm, and deployed an application on it. You saw that the
# core Docker commands didn’t change from part 3, they just had to be targeted
# to run on a swarm master. You also saw the power of Docker’s networking in
# action, which kept load-balancing requests across containers, even though they
# were running on different machines. Finally, you learned how to iterate and
# scale your app on a cluster.

docker-machine create --driver virtualbox myvm1                    # Create a VM
docker-machine env myvm1                # View basic information about your node
docker-machine ssh myvm1 "docker node ls"         # List the nodes in your swarm
docker-machine ssh myvm1 "docker node inspect <node ID>"        # Inspect a node
docker-machine ssh myvm1 "docker swarm join-token -q worker"   # View join token
docker-machine ssh myvm1   # Open an SSH session with the VM; type "exit" to end
docker node ls                # View nodes in swarm (while logged on to manager)
docker-machine ssh myvm2 "docker swarm leave"  # Make the worker leave the swarm
docker-machine ssh myvm1 "docker swarm leave -f" # Make master leave, kill swarm
docker-machine ls   # list VMs, asterisk shows which VM this shell is talking to
docker-machine start myvm1            # Start a VM that is currently not running
docker-machine env myvm1      # show environment variables and command for myvm1
eval $(docker-machine env myvm1)         # Mac command to connect shell to myvm1
docker stack deploy -c <file> <app>  # Deploy an app; command shell must be set 
#                            to talk to manager (myvm1), uses local Compose file
docker-machine scp docker-compose.yml myvm1:~     # Copy file to node's home dir 
#        (only required if you use ssh to connect to manager and deploy the app)
docker-machine ssh myvm1 "docker stack deploy -c <file> <app>"   # Deploy an app
#               using ssh (you must have first copied the Compose file to myvm1)
eval $(docker-machine env -u)     # Disconnect shell from VMs, use native docker
docker-machine stop $(docker-machine ls -q)               # Stop all running VMs
docker-machine rm $(docker-machine ls -q) # Delete all VMs and their disk images




################################################################################
#
# Docker get started - Part 5 - Stacks
#
################################################################################



# In part 4, you learned how to set up a swarm, which is a cluster of machines
# running Docker, and deployed an application to it, with containers running in
# concert on multiple machines.

# Here in part 5, you reach the top of the hierarchy of distributed
# applications: the stack. A stack is a group of interrelated services that
# share dependencies, and can be orchestrated and scaled together. A single
# stack is capable of defining and coordinating the functionality of an entire
# application (though very complex applications may want to use multiple stacks).

# Some good news is, you have technically been working with stacks since part 3,
# when you created a Compose file and used docker stack deploy. But that was a
# single service stack running on a single host, which is not usually what takes
# place in production. Here, you can take what you’ve learned, make multiple
# services relate to each other, and run them on multiple machines.


# Add a new service and redeploy

# It’s easy to add services to our docker-compose.yml file. First, let’s add a 
# free visualizer service that lets us look at how our swarm is scheduling 
# containers.

# We will use here a modified version of the previous docker-compose-part3.yml
# (use docker-compose-part5-1).

# The only thing new here is the peer service to web, named visualizer. Notice
# two new things here:
#   - a volumes key, giving the visualizer access to the host’s socket file for
#       Docker, and
#   - a placement key, ensuring that this service only ever runs on a swarm 
#       manager -- never a worker. That’s because this container, built from an 
#       open source project created by Docker, displays Docker services running
#       on a swarm in a diagram.

# We talk more about placement constraints and volumes in a moment.

# Make sure your shell is configured to talk to myvm1:
#   - Run docker-machine ls to list machines and make sure you are connected to
#       myvm1, as indicated by an asterisk next to it.
#   - If needed, re-run "docker-machine env myvm1", then run the following 
#       command to configure the shell:

$ eval $(docker-machine env myvm1)

# Re-run the docker stack deploy command on the manager, and whatever services 
# need updating are updated:

$ docker stack deploy -c docker-compose-part5-1.yml getstartedlab
# Updating service getstartedlab_web (id: angi1bf5e4to03qu9f93trnxm)
# Creating service getstartedlab_visualizer (id: l9mnwkeq2jiononb5ihz9u7a4)

# Take a look at the visualizer.

# You saw in the Compose file that visualizer runs on ²²² 8080. Get the IP 
# address of one of your nodes by running docker-machine ls. Go to either IP 
# address at port 8080 and you can see the visualizer running.

# The single copy of visualizer is running on the manager as you expect, and 
# the 5 instances of web are spread out across the swarm. You can corroborate 
# this visualization by running docker stack ps <stack>:

$ docker stack ps getstartedlab

# The visualizer is a standalone service that can run in any app that includes 
# it in the stack. It doesn’t depend on anything else. Now let’s create a 
# service that does have a dependency: the Redis service that provides a visitor
# counter.


# Persist the data

# Let’s go through the same workflow once more to add a Redis database for 
# storing app data. This is defined in the docker-compose-part5-2.yml file, 
# which finally adds a Redis service.

# Redis has an official image in the Docker library and has been granted the
# short image name of just redis, so no username/repo notation here. The Redis
# port, 6379, has been pre-configured by Redis to be exposed from the container
# to the host, and here in our Compose file we expose it from the host to the
# world, so you can actually enter the IP for any of your nodes into Redis
# Desktop Manager and manage this Redis instance, if you so choose.

# Most importantly, there are a couple of things in the redis specification
# that make data persist between deployments of this stack:
#   - redis always runs on the manager, so it’s always using the same 
#       filesystem.
#   - redis accesses an arbitrary directory in the host’s file system as /data 
#       inside the container, which is where Redis stores data.

# Together, this is creating a “source of truth” in your host’s physical
# filesystem for the Redis data. Without this, Redis would store its data in 
# /data inside the container’s filesystem, which would get wiped out if that 
# container were ever redeployed.

# This source of truth has two components:
#   - The placement constraint you put on the Redis service, ensuring that it 
#       always uses the same host.
#   - The volume you created that lets the container access ./data (on the host)
#       as /data (inside the Redis container). While containers come and go, the
#       files stored on ./data on the specified host persists, enabling
#       continuity.

# You are ready to deploy your new Redis-using stack.

# Create a ./data directory on the manager:

$ docker-machine ssh myvm1 "mkdir ./data"

# Make sure your shell is configured to talk to myvm1:
#   - Run docker-machine ls to list machines and make sure you are connected to
#       myvm1, as indicated by an asterisk next it.
#   - If needed, re-run docker-machine env myvm1, then run the given command to
#       configure the shell.

$ eval $(docker-machine env myvm1)

# Run docker stack deploy one more time.

$ docker stack deploy -c docker-compose-part5-2.yml getstartedlab

# Run docker service ls to verify that the three services are running as expected.

$ docker service ls
# ID                  NAME                       MODE                REPLICAS            IMAGE                             PORTS
# x7uij6xb4foj        getstartedlab_redis        replicated          1/1                 redis:latest                      *:6379->6379/tcp
# n5rvhm52ykq7        getstartedlab_visualizer   replicated          1/1                 dockersamples/visualizer:stable   *:8080->8080/tcp
# mifd433bti1d        getstartedlab_web          replicated          5/5                 gordon/getstarted:latest    *:80->80/tcp

# Check the web page at one of your nodes, such as http://192.168.99.101, and 
# take a look at the results of the visitor counter, which is now live and 
# storing information on Redis.

# Also, check the visualizer at port 8080 on either node’s IP address, and 
# notice see the redis service running along with the web and visualizer
# services.


# REMINDER FOR PART 4:

# You learned that stacks are inter-related services all running in concert, and
# that -- surprise! -- you’ve been using stacks since part three of this
# tutorial. You learned that to add more services to your stack, you insert them
# in your Compose file. Finally, you learned that by using a combination of 
# placement constraints and volumes you can create a permanent home for 
# persisting data, so that your app’s data survives when the container is torn 
# down and redeployed.
