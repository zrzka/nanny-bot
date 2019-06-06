FROM balenalib/jetson-nano-ubuntu:bionic-run as builder

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/src/app

RUN \
  apt-get update

RUN \
  apt-get install --no-install-recommends -y \  
  python3 \
  python3-setuptools \
  lbzip2 \
  curl \
  libavcodec57 \
  libavformat57 \
  libavutil55 \
  libcairo2 \
  libgdk-pixbuf2.0-0 \
  libgstreamer-plugins-base1.0-0 \
  libgstreamer1.0-0 libgtk2.0-0 \
  libjpeg8 \
  libpng16-16 \
  libswscale4 \
  libtbb2 \
  libtiff5 \
  libtbb-dev

# pytorch wheel size is 0.5GB (unpacked +-2GB) and pip isn't able to install it
# on a device with memory constraints without a swap. pip version 19.0 fixes this
# problem, but this version isn't available on Ubuntu (it uses 9). We have to
# install our own pip to be able to install pytorch wheel.
#
# https://github.com/pypa/pip/pull/5848
RUN python3 /usr/lib/python3/dist-packages/easy_install.py pip

# NVIDIA JetPack SDK & drivers (1.7GB)
ADD nvidia /usr/src/app/nvidia

# Install NVIDIA JetPack SDK & drivers & toolchain
# TODO: Uncomment cleanup
RUN \
  dpkg -i nvidia/deb/cuda-repo-l4t-10-0-local-10.0.166_1.0-1_arm64.deb && \  
  apt-key add /var/cuda-repo-10-0-local-10.0.166/*.pub && \
  apt-get update && \
  apt-get install -y cuda-cublas-10-0 cuda-cudart-10-0 cuda-toolkit-10-0 && \
  # dpkg --remove cuda-repo-l4t-10-0-local-10.0.166 && \
  # dpkg -P cuda-repo-l4t-10-0-local-10.0.166 && \
  rm nvidia/deb/cuda-repo-l4t-10-0-local-10.0.166_1.0-1_arm64.deb && \
  dpkg -i nvidia/deb/*.deb && \
  tar xjf nvidia/nvidia_drivers.tbz2 -C / && \
  tar xjf nvidia/config.tbz2 -C / --exclude=etc/hosts --exclude=etc/hostname && \
  echo "/usr/lib/aarch64-linux-gnu/tegra" > /etc/ld.so.conf.d/nvidia-tegra.conf && \
  ldconfig
#  rm -rf nvidia

# Install prebuilt wheels from the https://github.com/zrzka/python-wheel-aarch64 repository
#
# Don't try to build pytorch:
#
#   * build folder size is 10GB
#   * it takes more than a day on the Jetson Nano (+-1 hour on balena builders)
#   * 4GB of RAM isn't enough
#
# Here's the source for these wheels (how I built them):
#
#   * https://github.com/zrzka/python-wheel-aarch64/tree/master/ubuntu-18-04-python-3-6
RUN \
  mkdir wheel && \
  curl -sSL https://github.com/zrzka/python-wheel-aarch64/releases/download/jetson-nano-1.0/grpcio-1.21.1-cp36-cp36m-linux_aarch64.whl --output wheel/grpcio-1.21.1-cp36-cp36m-linux_aarch64.whl && \
  curl -sSL https://github.com/zrzka/python-wheel-aarch64/releases/download/jetson-nano-1.0/h5py-2.9.0-cp36-cp36m-linux_aarch64.whl --output wheel/h5py-2.9.0-cp36-cp36m-linux_aarch64.whl && \
  curl -sSL https://github.com/zrzka/python-wheel-aarch64/releases/download/jetson-nano-1.0/numpy-1.16.4-cp36-cp36m-linux_aarch64.whl --output wheel/numpy-1.16.4-cp36-cp36m-linux_aarch64.whl && \
  curl -sSL https://github.com/zrzka/python-wheel-aarch64/releases/download/jetson-nano-1.0/pyzmq-18.0.1-cp36-cp36m-linux_aarch64.whl --output wheel/pyzmq-18.0.1-cp36-cp36m-linux_aarch64.whl && \
  curl -sSL https://github.com/zrzka/python-wheel-aarch64/releases/download/jetson-nano-1.0/torch-1.1.0-cp36-cp36m-linux_aarch64.whl --output wheel/torch-1.1.0-cp36-cp36m-linux_aarch64.whl && \
  pip3 install -U --no-cache-dir wheel/grpcio-1.21.1-cp36-cp36m-linux_aarch64.whl && \
  pip3 install -U --no-cache-dir wheel/numpy-1.16.4-cp36-cp36m-linux_aarch64.whl && \
  pip3 install -U --no-cache-dir wheel/h5py-2.9.0-cp36-cp36m-linux_aarch64.whl && \
  pip3 install -U --no-cache-dir wheel/pyzmq-18.0.1-cp36-cp36m-linux_aarch64.whl && \
  pip3 install -U --no-cache-dir wheel/torch-1.1.0-cp36-cp36m-linux_aarch64.whl && \
  rm -rf wheel

# JetBot dependencies
# https://docs.nvidia.com/deeplearning/frameworks/install-tf-xavier/index.html
# https://github.com/NVIDIA-AI-IOT/jetbot/wiki/Software-Setup
RUN \
  apt-get install --no-install-recommends -y zlib1g-dev zip libjpeg8 libhdf5-100 python3-dev git cmake pkg-config python3-pillow && \
  pip3 install -U --no-cache-dir wheel && \
  pip3 install -U --no-cache-dir traitlets ipywidgets && \
  pip3 install -U --no-cache-dir absl-py py-cpuinfo psutil portpicker six mock requests gast astor termcolor && \
  pip3 install -U --no-cache-dir --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu==1.13.1+nv19.5

# JetBot
# TODO: Uncomment cleanup
RUN \
  git clone -b v0.3.0 --single-branch --depth 1 https://github.com/NVIDIA-AI-IOT/jetbot.git && \
  cd jetbot && \
  python3 setup.py install
#  cd .. && rm -rf jetbot  

ENV UDEV 1

CMD [ "sleep", "infinity" ]

# Run image
#
# 2.3GB
# COPY --from=builder /usr/local/cuda-10.0 /usr/local/cuda-10.0
# 
# 1.3GB
# COPY --from=builder /usr/lib/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu
#
# 3.0GB (mainly because of 2.0GB pytorch)
# COPY --from=builder /usr/local/lib /usr/local/lib
#
# nvidia_drivers.tbz2 & config.tbz2 dance
