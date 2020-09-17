#!/usr/bin/env bash
set -o errexit

echo "Create a container"
container=$(buildah from fedora:21)

echo "Labels are part of the buildah config command"
buildah config --label maintainer="Mohsin Shaikh <mohsin.shaikh@kaust.edu.sa>" $container

echo "Grab the source code outside of the container"
curl -sSL http://ftpmirror.gnu.org/hello/hello-2.10.tar.gz -o hello-2.10.tar.gz

buildah copy $container hello-2.10.tar.gz /tmp/hello-2.10.tar.gz
buildah run $container yum install -y tar gzip autoconf libtool automake make texinfo
buildah run $container yum clean all
buildah run $container tar xvzf /tmp/hello-2.10.tar.gz -C /opt

echo "Workingdir is also a buildah config command"
buildah config --workingdir /opt/hello-2.10 $container

buildah run $container ./configure
buildah run $container make
buildah run $container make install
buildah run $container hello -v

echo "Entrypoint, too, is a buildah config command"
buildah config --entrypoint /usr/local/bin/hello $container

echo "Finally saves the running container to an image"
buildah commit --format docker $container hello:latest
