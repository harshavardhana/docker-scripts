#!/usr/bin/env bash
#
# Create a base Red Hat Storage Server docker image.
#
# Inspired from mkimage-yum.sh from `docker/contrib`
#

init ()
{
    yum_config=$1
    target=$(mktemp -d --tmpdir $(basename $0).XXXXXX)

    mkdir -m 755 "$target"/dev
    mknod -m 600 "$target"/dev/console c 5 1
    mknod -m 600 "$target"/dev/initctl p
    mknod -m 666 "$target"/dev/full c 1 7
    mknod -m 666 "$target"/dev/null c 1 3
    mknod -m 666 "$target"/dev/ptmx c 5 2
    mknod -m 666 "$target"/dev/random c 1 8
    mknod -m 666 "$target"/dev/tty c 5 0
    mknod -m 666 "$target"/dev/tty0 c 4 0
    mknod -m 666 "$target"/dev/urandom c 1 9
    mknod -m 666 "$target"/dev/zero c 1 5
}

cleanup ()
{
    # effectively: febootstrap-minimize --keep-zoneinfo --keep-rpmdb
    # --keep-services "$target".  Stolen from mkimage-rinse.sh
    #  locales
    rm -rf "$target"/usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}
    #  docs
    rm -rf "$target"/usr/share/{man,doc,info,gnome/help}
    #  cracklib
    rm -rf "$target"/usr/share/cracklib
    #  i18n
    rm -rf "$target"/usr/share/i18n
    #  sln
    rm -rf "$target"/sbin/sln
    #  ldconfig
    rm -rf "$target"/etc/ld.so.cache
    rm -rf "$target"/var/cache/ldconfig/*
}

prepare ()
{
    yum -c "$yum_config" --installroot="$target" --setopt=tsflags=nodocs \
        --setopt=group_package_types=mandatory -y install glusterfs-server glusterfs-fuse glusterfs nfs-utils rpcbind redhat-storage-server
    yum -c "$yum_config" --installroot="$target" -y clean all
}

post ()
{
    cat > "$target"/etc/sysconfig/network <<EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF
}

create ()
{
    name=$1
    version=$2

    tar --numeric-owner -c -C "$target" . | docker import - $name:$version
    docker run -i -t $name:$version glusterfs --version
    rm -rf "$target"
}

usage ()
{
    echo "$0 <path_to_yum_config> <image_repo> <image_tag>" && exit 1;
}

main ()
{
    if [ $# -ne 3 ]; then
        echo "Not enough arguments";
        usage;
    fi

    init $1;
    prepare;
    post;
    cleanup;

    create $2 $3;
}

main "$@"
