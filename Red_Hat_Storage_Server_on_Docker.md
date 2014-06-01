First Step
====

To start with follow below instructions to get Red Hat Storage Server installed

[Obtaining Red Hat Storage Server for On-Premise][1]

[Registration to the Red Hat Network (RHN)][2]

[Installing Red Hat Storage Server][3]

  [1]: https://access.redhat.com/site/documentation/en-US/Red_Hat_Storage/2.1/html-single/Installation_Guide/index.html#idm95532016
  [2]: https://access.redhat.com/site/documentation/en-US/Red_Hat_Storage/2.1/html-single/Installation_Guide/index.html#chap-Installation_Guide-Register_RHN
  [3]: https://access.redhat.com/site/documentation/en-US/Red_Hat_Storage/2.1/html-single/Installation_Guide/index.html#chap-Installation_Guide-Install_RHS

Second Step
====

Verify installation is complete

    # cat /etc/redhat-storage-server
    Red Hat Storage Server 2.1 Update 2

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

Download script from `docker-scripts` project https://github.com/harshavardhana/docker-scripts/blob/master/mkimage-rhs.sh

NOTE: ``--privileged`` is necessary for the fact that GlusterFS server daemons want `CAP_SYS_ADMIN` capability - allowing extended attribute support without this option one would see ENOPNOTSUPP returned by the underlying filesystem.

Fourth Step
====

Now inside the docker container we might want to test out GlusterFS volume creation

Start portmap for running NFS services

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


Now you have your own Scale Out Red Hat Storage Server docker container! - Enjoy :-)