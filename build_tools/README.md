# build_tools
This directory contains tools for building the main firmware image, that gets put on the sdcard.

## Build It!
### ... with docker
The build scripts are intendet to be run inside a docker container with `ubuntu:17.04` and the dependencies in the `dependencies.txt` file installed. 

First you have to get a shell in your docker container:
```
docker run -it ubuntu:17.04 /bin/bash
```
After this, install git and clone this repo inside the container:
```
apt get update && apt install -y git
git clone https://github.com/apertus-open-source-cinema/beta-software
cd beta software
```
Then install the missing dependencies and start the build process:
```
build_tools/full_build_ubuntu.sh
```


### ... without containerisation
The preffered and tested build environment is Ubuntu 17.04.
Other Ubuntu installations should work as well, as long as they are new enough that `mke2fs` has a `-d` option (Ubuntu 16.04 and below dont work).

To run the build, follow instructions of the docker section without creating the container.