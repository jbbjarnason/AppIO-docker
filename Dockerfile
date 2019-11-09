FROM ubuntu:19.10

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    wget \
    g++-aarch64-linux-gnu \
    #g++-arm-linux-gnueabihf \
    cmake \
    rapidjson-dev \
    nlohmann-json3-dev

WORKDIR /home

RUN git clone --progress --verbose https://github.com/raspberrypi/tools.git --depth=1 pitools

RUN touch ~/user-config.jam && echo "using gcc : arm : aarch64-linux-gnu-g++ ;" >> ~/user-config.jam
#RUN touch ~/user-config.jam && echo "using gcc : arm : arm-linux-gnueabihf-g++ ;" >> ~/user-config.jam

# Download boost, untar, setup install with bootstrap and then install
RUN wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz \
    && tar xfz boost_1_67_0.tar.gz \
    && rm boost_1_67_0.tar.gz \
    && cd boost_1_67_0 \
    && ./bootstrap.sh --prefix=/usr/local \
    && ./b2 -j 12 address-model=64 architecture=arm toolset=gcc-arm install \
#   && ./b2 -j 12 address-model=32 architecture=arm toolset=gcc-arm install \
    && cd /home \
    && rm -rf boost_1_67_0

RUN git clone --progress --verbose https://github.com/raspberrypi/userland.git userland \
	&& cd userland \
	&& cp makefiles/cmake/toolchains/aarch64-linux-gnu.cmake ../toolchain.cmake #arm-linux-gnueabihf.cmake

RUN git clone --progress --verbose https://github.com/zeromq/libzmq.git libzmq \
    && cd libzmq \
    && mkdir build \
    && cd build \
    && cmake -DENABLE_CPACK=ON -DCMAKE_TOOLCHAIN_FILE=/home/toolchain.cmake .. \
    && make -j 12 \
    && make install

RUN git clone --progress --verbose https://github.com/zeromq/azmq.git azmq \
    && cd azmq \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_TOOLCHAIN_FILE=/home/toolchain.cmake .. \
    && make -j 12 \
    && make install \
    && cpack -G DEB -D CPACK_DEBIAN_PACKAGE_MAINTAINER=ME

RUN git clone --progress --verbose https://github.com/jbbjarnason/AppIO.git appio \
    && cd appio \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_TOOLCHAIN_FILE=/home/toolchain.cmake .. \
    && make -j 12 \
    && make install

RUN git clone --progress --verbose https://github.com/joan2937/pigpio.git pigpio \
    && cd pigpio \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_TOOLCHAIN_FILE=/home/toolchain.cmake .. \
    && make -j 12 \
    && make install

ENV BUILD_FOLDER /build

WORKDIR ${BUILD_FOLDER}

CMD ["mkdir", "${BUILD_FOLDER}/cmake-build-docker"]
WORKDIR ${BUILD_FOLDER}/cmake-build-docker

CMD ["/bin/bash", "-c", "cmake -DCMAKE_TOOLCHAIN_FILE=/home/toolchain.cmake .. && make -j 12"]
