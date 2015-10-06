#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

umask 022

set -e
set -x

apt-get update -yq
apt-get install --no-install-suggests -yq python-software-properties
add-apt-repository -y ppa:chris-lea/redis-server
apt-get update -yq
apt-get install --no-install-suggests -yq \
  build-essential \
  byobu \
  curl \
  git \
  make \
  redis-server \
  screen

su - vagrant -c /vagrant/.vagrant-provision-as-vagrant.sh
