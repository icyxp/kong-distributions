# Building Kong distributions

Kong can be distributed to different platforms such as CentOS, Debian, Ubuntu and OS X. Here you find the scripts that will start the build process and output packages.

# Requirements

- OS X
- [Docker](https://www.docker.com/)

# Build

- Help

```shell
./build-package.sh -h
```

- Building for every platform:

```shell
./build-package.sh -k [KONG_TAG_OR_BRANCH] -p all [-t]
```

- Building for specific platforms:

```shell
./build-package.sh -k [KONG_TAG_OR_BRANCH] -p "osx centos:5 debian:8" [-t]
```

Distributions will be placed under the `build-output` folder (should the folder not exist it will be automatically created).

**Warning:** **Do not execute** the `.build-package-script.sh` file, it's used internally by the build.

# Release on Bintray

- Help

```shell
./bintray-release.sh -h
```

- Releasing every platform:

```shell
./bintray-release.sh -u [BINTRAY USERNAME] -k [BINTRAY KEY] -v [KONG VERSION] -p all
```

- Releasing for specific platforms:

```shell
./bintray-release.sh -u [BINTRAY USERNAME] -k [BINTRAY KEY] -v [KONG VERSION] -p centos:5 debian:8
```


## Supported Platforms

- `all`
- `centos:6`
- `centos:7`
- `debian:7`
- `debian:8`
- `ubuntu:12.04.5`
- `ubuntu:14.04.2`
- `ubuntu:15.04`
- `ubuntu:16.04`
- `osx`
- `aws`
