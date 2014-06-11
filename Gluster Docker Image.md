# Community Gluster on Docker

If you would like to try out gluster, a new docker container is available on the [docker hub][1].

## Usage
### Prepare an XFS mount

The preferred method to use gluster is to mount an XFS partition. If you do not have an XFS partition on your system, you can create and mount one using the following commands:

```sh
dd if=/dev/zero of=/data/gluster.xfs bs=1M count=2048
mkfs.xfs -isize=512 /data/gluster.xfs
mkdir /mnt/gluster
mount -oloop,inode64,noatime /data/gluster.xfs /mnt/gluster
```

### Run docker with the XFS mount

```sh
docker run --privileged -i -t -h gluster -v /mnt/gluster:/mnt/vault gluster/gluster:latest /bin/bash
bash-4.1# df -h /mnt/vault
Filesystem      Size  Used Avail Use% Mounted on
/dev/loop4     2014M   45M  1969M   4% /mnt/vault
bash-4.1#
```

### Access your new gluster volume from the host


Grab the ip address for the container
```sh
GLUSTER_CONTAINER_ID=$(docker ps | grep -i gluster | awk {'print $1'}
GLUSTER_IPADDR=$(docker inspect $GLUSTER_CONTAINER_ID | grep -i ipaddr | sed -e 's/\"//g' -e 's/\,//g' | awk {'print $2'})
```

Mount a container using the ip address provided in the above section.

```sh
mount -t glusterfs ${GLUSTER_IPADDR}:$VOLUME_NAME /mnt/gfs
```

### Accessing your new gluster volume from a contaner

Docker drops CAP_SYS_ADMIN which prevents the user from mounting a container from within another container. You can still access the volume but you must use the volume mounted from the host.

First, mount the volume to the host as in the previous section.

Second, mount the volume on container run

```sh
docker run -i -t -h gluster-client -v /mnt/gfs:/mnt/${VOLUME_NAME} gluster/gluster:latest /bin/bash
# verify /mnt/gfs is mounted in your volume.
```

  [1]: https://registry.hub.docker.com/u/gluster/gluster/
