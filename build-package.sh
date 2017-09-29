#!/bin/bash

set -o errexit

##############################################################
#                      Parse Arguments                       #
##############################################################

function usage {
cat << EOF
usage: $0 options

This script build Kong in different distributions

OPTIONS:
 -h      Show this message
 -k      Kong version to build
 -p      Platforms to target
 -t      Execute tests
EOF
}

ARG_PLATFORMS=
KONG_VERSION=
TEST=false
while getopts "hk:p:t" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    k)
      KONG_VERSION=$OPTARG
      ;;
    p)
      ARG_PLATFORMS=$OPTARG
      ;;
    t)
      TEST=true
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [[ -z $ARG_PLATFORMS ]] || [[ -z $KONG_VERSION ]]; then
  usage
  exit 1
fi

# Check system
if [[ "$OS" =~ Windows ]]; then
  echo "Run this script from a *nix system"
  exit 1
fi

##############################################################
#                      Check Arguments                       #
##############################################################

supported_platforms=( centos:6 centos:7 debian:7 debian:8 ubuntu:12.04.5 ubuntu:14.04.2 ubuntu:15.04 ubuntu:16.04 osx )
platforms_to_build=( )

for var in "$ARG_PLATFORMS"
do
  if [[ "all" == "$var" ]]; then
    platforms_to_build=( "${supported_platforms[@]}" )
  elif ! [[ " ${supported_platforms[*]} " == *" $var "* ]]; then
    echo "[ERROR] \"$var\" not supported. Supported platforms are: "$( IFS=$'\n'; echo "${supported_platforms[*]}" )
    echo "You can optionally specify \"all\" to build all the supported platforms"
    exit 1
  else
    platforms_to_build+=($var)
  fi
done

if [ ${#platforms_to_build[@]} -eq 0 ]; then
  echo "Please specify an argument!"
  exit 1
fi

echo "Building Kong $KONG_VERSION: "$( IFS=$'\n'; echo "${platforms_to_build[*]}" )

##############################################################
#                        Start Build                         #
##############################################################

# Preparing environment
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "Current directory is: "$DIR
if [ "$DIR" == "/" ]; then
  DIR=""
fi

# Delete previous packages
rm -rf $DIR/build-output

for i in "${platforms_to_build[@]}"
do
  echo "Building for $i"
done

# Start build
for i in "${platforms_to_build[@]}"
do
  # Deleting Docker images
  #docker rm -f $(docker ps -a -q) || true
  #docker rmi -f $(docker images -q) || true
  echo "Building for $i"
  if [[ "$i" == "osx" ]]; then
    /bin/bash $DIR/.build-package-script.sh ${KONG_VERSION}
  elif [[ "$i" == "aws" ]]; then
    echo "TODO: Build on AWS Linux AMI!"
  else
    docker pull $i # Because of https://github.com/CentOS/CentOS-Dockerfiles/issues/33
    docker run -v $DIR/:/build-data $i /bin/bash -c "/build-data/.build-package-script.sh ${KONG_VERSION}"
  fi
  if [ $? -ne 0 ]; then
    echo "Error building for $i"
    exit 1
  fi

  # Check if tests are enabled, and execute them
  if [[ $TEST == true ]]; then
    echo "Testing $i"
    last_file=$(ls -dt $DIR/build-output/* | head -1)
    last_file_name=`basename $last_file`
    if [[ "$i" == "osx" ]]; then
      /bin/bash $DIR/.test-package-script.sh $DIR/build-output/$last_file_name
    elif [[ "$i" == "aws" ]]; then
      echo "TODO: Test on AWS Linux AMI!"
    else
      docker run -v $DIR/:/build-data $i /bin/bash -c "/build-data/.test-package-script.sh /build-data/build-output/$last_file_name"
    fi
    if [ $? -ne 0 ]; then
      echo "Error testing for $i"
      exit 1
    fi
  fi
done

echo "Build done"
