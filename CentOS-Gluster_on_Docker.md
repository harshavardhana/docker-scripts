First Step
====

To start with follow CentOS installation instructions. 

[CentOS 6.5 Release Notes][1]

Second Step
====

Verify installation is complete

    # cat /etc/redhat-release 
    CentOS release 6.5 (Final)

Install necessary tools for local docker build later

    # yum install git make -y

Third Step
====

Install `docker-io`, `lxc` and `lxc-libs` from EPEL repository 

    # yum install http://dl.fedoraproject.org/pub/epel/6/x86_64/lxc-libs-0.9.0-2.el6.x86_64.rpm
    # yum install http://dl.fedoraproject.org/pub/epel/6/x86_64/lxc-0.9.0-2.el6.x86_64.rpm
    # yum install http://dl.fedoraproject.org/pub/epel/6/x86_64/docker-io-0.11.1-4.el6.x86_64.rpm

Once the installation is complete, turn off automatic start of docker, its only needed since we are going to build `docker` locally and docker build uses`docker` to build itself. 

    # chkconfig docker off
    # service docker start
    # git clone https://github.com/dotcloud/docker.git
    # cd docker; make
    ....
    ....
    Removing intermediate container 95b632e6edf5
    Successfully built 434f0b5874fa
    docker run --rm -it --privileged -e TESTFLAGS -e TESTDIRS -e     DOCKER_GRAPHDRIVER -e DOCKER_EXECDRIVER -v "/root/docker/bundles:/go/src/github.com/dotcloud/docker/bundles" "docker:master" hack/make.sh binary
    
    ---> Making bundle: binary (in bundles/0.11.1-dev/binary)
    Created binary: /go/src/github.com/dotcloud/docker/bundles/0.11.1-dev/binary/docker-0.11.1-dev

Open new terminal

    # service docker stop
    # cd docker;
    # ./bundles/0.11.1-dev/binary/docker -d

Fourth Step
=====

Install GlusterFS upstream repo 

    # wget http://download.gluster.org/pub/gluster/glusterfs/3.5/3.5.0/CentOS/glusterfs-epel.repo -O /etc/yum.repos.d/glusterfs-epel.repo
    
Verify if the repository installation is complete with below command

    # yum search glusterfs-server

Download script from `docker-scripts` project https://github.com/harshavardhana/docker-scripts/blob/master/mkimage-centos.sh

Once the image is built verify with following command

    # docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    y4m4/centos6                 glusterfs-3.5                3042eb6ba17c        2 minutes ago       179.2 MB

Now initiate a container using this image

    # docker run --name centos-gluster -i -t --privileged y4m4/centos6:glusterfs-3.5 /bin/bash

NOTE: ``--privileged`` is necessary for the fact that GlusterFS server daemons want `CAP_SYS_ADMIN` capability - allowing extended attribute support without this option one would see ENOPNOTSUPP (Operation not supported) returned by the underlying filesystem. 

Fifth Step
====

Now inside the docker container we might want to test out GlusterFS volume creation 

Start portmap for running NFS services (Optional - turn off if not needed)

    # service rpcbind start
    
Start glusterd for Gluster management daemon
  
    # service glusterd start

Create volume

    # ifconfig eth0
    # gluster volume create test 172.17.0.3:/brick/test force
    
    # gluster volume start test
    # showmount -e
    Export list for b445b223852f:
    /test *
    
    # gluster volume status test
    Status of volume: test
    Gluster process                                         Port    Online  Pid
    ------------------------------------------------------------------------------
    Brick 172.17.0.3:/mnt/test                              49152   Y       294
    NFS Server on localhost                                 2049    Y       398

    Task Status of Volume test
    ------------------------------------------------------------------------------
    There are no active volume tasks


Now you have your own Scale out CentOS/GlusterFS docker container! - Enjoy :-)


  [1]: http://wiki.centos.org/Manuals/ReleaseNotes/CentOS6.5
