# Docker volume plugin for GlusterFS

### Disclaimer

_This plugin was forked from [urbitechsro/docker-volume-glusterfs](https://github.com/urbitechsro/docker-volume-glusterfs) which, in turn, was forked from [mikebarkmin/docker-volume-glusterfs](https://github.com/mikebarkmin/docker-volume-glusterfs)_

This is a managed Docker volume plugin to allow Docker containers to access
GlusterFS volumes.
The GlusterFS client does not need to be installed on the
host and everything is managed within the plugin.

[![Go Report Card](https://goreportcard.com/badge/github.com/HeavenVolkoff/docker-volume-glusterfs)](https://goreportcard.com/report/github.com/HeavenVolkoff/docker-volume-glusterfs)

## Usage

0 - Build and enable the plugin

```sh
$>  ./build.sh
```

1 - Change the plugin default options (OPTIONAL)

```sh
$>  docker plugin set SERVERS=<server1,server2,...,serverN> VOLNAME=<volname> DEBUG=<0|1>
```

2 - Create a volume

```sh
$>  docker volume create -d glusterfs \
        -o servers=<server1,server2,...,serverN> \
        -o volname=<volname> \
        -o subdir=<subdir> \
        glustervolume
glustervolume

$>  docker volume ls
DRIVER           VOLUME NAME
glusterfs:next   glustervolume
```

or if you set the defaults for the plugin, you can create a volume without any options:

```sh
$>  docker volume create -d glusterfs glustervolume
glustervolume

$>  docker volume ls
DRIVER           VOLUME NAME
glusterfs:next   glustervolume
```

3 - Use the volume

```sh
$>  docker run -it -v glustervolume:<path> bash ls <path>
```

## Options

- **servers** _[required, if no default set]_:
  
    >Comma separated list of servers e.g.: 192.168.2.1,192.168.1.1

- **volname** _[required, if no default set]_

    >Name of the glusterfs volume e.g.: gv0
    >
    >_Must be a volume that already exists in the gluster cluster_

- **subdir** _[optional, default: volume name]_

    >The name of the subdir.
    >
    >_Will be created, if not found._

For additional options see [mount.glusterfs manual](https://github.com/gluster/glusterfs/blob/release-6/doc/mount.glusterfs.8).

## LICENSE

[MIT](./LICENSE)
