#!/usr/bin/env sh

set -eu

# Choose for which architecture you whish to build the plugin for
_arch=arm64 # amd64 | arm-v6 | arm-v7 | s390x | ppc64le | ...

# The tag of the debian image determines which version of glusterfs is installed
# See here for available versions per release:
# https://packages.debian.org/search?searchon=names&keywords=glusterfs-client#psearchres
_debian=bookworm-slim

# Plugin version, Check Dockerfile labels to see what is the current version
_version=1.2.0-7

__dir=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)
__plugin="${__dir}/plugin/${_arch}"

# Build roots
docker buildx \
  --tag "docker-volume-glusterfs:${_arch}_${_version}" \
  --load \
  --platform "linux/${_arch}" \
  --build-arg "DEBIAN_VERSION=${_debian}" \
  "$__dir"

# Export plugin rootfs
mkdir -p "${__plugin}/rootfs"
docker create --name tmp "docker-volume-glusterfs:${_arch}_${_version}"
docker export tmp | tar -x -C "${__plugin}/rootfs"

# Create plugin
cp config.json "${__plugin}"
docker plugin rm -f "glusterfs"
docker plugin create "glusterfs" "${__plugin}"
docker plugin enable "glusterfs" "${__plugin}"

# Cleanup
docker rm -vf tmp
docker image rm -f "docker-volume-glusterfs:${_arch}_${_version}"
rm -rf "${__plugin}"
