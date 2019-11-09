# AppIO-docker
Cross compile AppIO with docker
## Example
To create your docker:
```bash
$ cd ~/Downloads
$ git clone https://github.com/jbbjarnason/AppIO-docker.git
$ docker build -t appio-aarch64 ~/Downloads/AppIO-docker/
```
To use the docker:
```bash
$ cd ~/Downloads
$ git clone https://github.com/jbbjarnason/AppIO.git
$ docker run -it -v ~/Downloads/AppIO:/build appio-aarch64
```
