# Gluster on Docker

[TOC]

## Abstract

In this document, we discuss running gluster within docker including challenges, solutions to those challenges, and a proposed approach. We have also included a brief tutorial on how to get gluster working within docker.

## Technical Challenges

### Latest stable version does not support fuse

Fuse support has been added and should be supported in the next release.

### Docker AUFS does not support xattr

Red Hat systems are not directly affected by this because the backend storage driver is LVM+DM instead of AUFS.

For systems running AUFS (e.g. Ubuntu), docker will need to use the BTRFS driver.

### Gluster Daemon requires CAP_SYS_ADMIN for storing metadata

Gluster stores most of its file metadata using the trusted extended attribute class. Viewing or modifying trusted xattr requires CAP_SYS_ADMIN. Trusted containers may be executed with the ```--privileged``` flag to receive CAP_SYS_ADMIN. **Untrusted containers or containers executing untrusted user applications/scripts or commands must not be executed with --privileged or receive CAP_SYS_ADMIN**

#### Resolution

Gluster servers must be fully managed for the user when running in a docker container. A gluster container image can be released to the user for on-premise execution, but should not be imported back in.

### Mounting directories requires CAP_SYS_ADMIN

When CAP_SYS_ADMIN is provided to a docker client, the container may mount gluster volumes without any issues. For untrusted containers,

#### Resolution

For now, the mount must also be managed for them.

A recommended improvement to docker is to provide a backend mount driver capable of mounting glusterfs on execution. Cleanup (unmounting) should also be performed by the backend driver when the container is shut down. This would eliminate the need for external tooling to manage mappings between containers and mounts and increase the overall robustness of hte system.

### Gluster Containers must use virtual ip address instead of port redirecting

Gluster must be accessible over the real ports that are exposed. Docker on Fedora and CentOS both assign a virtual IP address, so this should not be an issue. 

### Gluster may have problems with being assigned a new IP address for an existing volume

Gluster volumes are bound directly to an IP address, and break if the IP address is changed.

Gluster may need to be modified to support this use case.

## Gluster on RHS 2.1

[Please see accompanying document][1]

## Gluster on CentOS

[Please see accompanying document][2]


  [1]: https://github.com/harshavardhana/docker-scripts/blob/master/Red_Hat_Storage_Server_on_Docker.md
  [2]: https://github.com/harshavardhana/docker-scripts/blob/master/CentOS-Gluster_on_Docker.md
