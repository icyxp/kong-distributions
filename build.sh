#!/bin/bash

./build-package.sh -k feat/0.11.2 -p "build_kong:7"
./build-package.sh -k feat/0.11.2 -p "build_kong:6"
