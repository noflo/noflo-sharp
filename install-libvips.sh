#!/bin/bash
set -ex
wget http://void.cc/libvips-precise64.tar.gz
tar -xvzf libvips-precise64.tar.gz -C /usr/local
echo $PKG_CONFIG_PATH
