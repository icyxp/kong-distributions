#!/bin/bash

./build-package.sh -k feat/0.14.0 -p "build_kong:7"
./build-package.sh -k feat/0.14.0 -p "build_kong:6"
