#!/bin/bash
set -ex
wget https://s3-us-west-2.amazonaws.com/cdn.thegrid.io/caliper/libvips/libvips-precise64.tar.gz
tar -xvzf libvips-precise64.tar.gz -C /usr/local
