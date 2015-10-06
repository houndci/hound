#!/bin/bash

set -e
set -x

ln -svf /vagrant/.vagrant-skel/bashrc ~/.bashrc
ln -svf /vagrant/.vagrant-skel/bash_profile ~/.bash_profile

source ~/.bashrc

set +x
curl -L https://get.rvm.io | bash -s stable --ruby=2.0.0 --auto-dotfiles

source ~/.rvm/scripts/rvm
gem install --no-ri --no-rdoc bundler foreman
