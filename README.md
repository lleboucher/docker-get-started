# docker-get-started

This 'project' is CLOSED - I had to split it in four parts:

1. learn-docker:
        This is about the basics of docker, and practising a bit on Ubuntu, 
        building swarm, stacks... with docker-compose and docker-machine.
        
2. learn-vagrant:
        This is about the basics of vagrant, used here to automate the 
        production a replicable - reproductible VM for development environments
        and also building up sets of VM (for instance to build a K8s cluster).
        
3. learn-kubernetes:
        This is about the basics of Kubernetes, from setting up a cluster on 
        3 VMs, to deploying a simple stateless app, deploying a stateful app,
        and finally deploying a cassandra cluster.
        
4. learn-kind:
        This is about the basics of KinD (Kubernetes in Docker), a smart 
        initiative aiming at enabling the deployment of K8s learning 
        environments on containers and not on VMs. It makes it easier and 
        faster to deploy clusters, and thus enable to focus on how to play
        with K8s instead of deploying it.
        
Any good will is welcome to help debugging the third one, where I still 
face issues with the overlay network setup (typically, facing known limitations 
of Flannel on top of K8S deployed with vagrant).

Thank you for reading :-)
