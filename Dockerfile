# Copyright 2019 The MediaPipe Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:20.04

MAINTAINER <mediapipe@google.com>

WORKDIR /io
WORKDIR /mediapipe

ENV DEBIAN_FRONTEND=noninteractive

# removed opencv installation 
#
# libopencv-core-dev \
# libopencv-highgui-dev \
# libopencv-imgproc-dev \
# libopencv-video-dev \
# libopencv-calib3d-dev \
# libopencv-features2d-dev \


RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc-8 g++-8 \
        ca-certificates \
        curl \
        ffmpeg \
        git \
        wget \
        unzip \
        nodejs \
        python3-opencv \
        npm \
        python3-dev \
        python3-pip \
        software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && apt-get install -y openjdk-8-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

    # check if we need mesa for development...
    # apt-get install -y mesa-common-dev libegl1-mesa-dev libgles2-mesa-dev && \
    # apt-get install -y mesa-utils && \


RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100 --slave /usr/bin/g++ g++ /usr/bin/g++-8
RUN pip3 install --upgrade setuptools
RUN pip3 install wheel
RUN pip3 install future
RUN pip3 install absl-py numpy opencv-contrib-python protobuf==3.20.1
RUN pip3 install six==1.14.0
RUN pip3 install tensorflow
RUN pip3 install tf_slim

RUN ln -s /usr/bin/python3 /usr/bin/python

# Setup opencv
RUN chmod +x ./setup_opencv.sh && ./setup_opencv.sh &&\
    echo "export CPLUS_INCLUDE_PATH=/usr/local/include/opencv2:$CPLUS_INCLUDE_PATH" >> /root/.bashrc &&\
    echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" >> /root/.bashrc

# Install bazel
RUN wget -O bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v1.15.0/bazelisk-linux-amd64 &&\
    chmod +x bazelisk &&\
    mv bazelisk /usr/bin/bazelisk

COPY . /mediapipe/

# run build
RUN chmod +x ./build_desktop_examples.sh &&\
    ./build_desktop_examples.sh -b

# If we want the docker image to contain the pre-built object_detection_offline_demo binary, do the following
# RUN bazel build -c opt --define MEDIAPIPE_DISABLE_GPU=1 mediapipe/examples/desktop/demo:object_detection_tensorflow_demo
