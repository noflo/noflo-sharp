#!/bin/bash
set -ex
wget http://void.cc/libvips-precise64.tar.gz
tar -xvzf libvips-precise64.tar.gz -C /usr/local
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
echo $PKG_CONFIG_PATH
