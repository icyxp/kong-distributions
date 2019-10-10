#!/bin/bash

./build-package.sh -k feat/0.14.1 -p "icyboy/build_kong:0.14.x-centos7"
./build-package.sh -k feat/0.14.1 -p "icyboy/build_kong:0.14.x-centos6"
