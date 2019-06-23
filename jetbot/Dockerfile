FROM balenalib/jetson-nano-ubuntu:bionic-run as builder

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/src/app

RUN \
  apt-get update && \
  apt-get install --no-install-recommends -y \  
  python3 \
  python3-setuptools \
  lbzip2 \
  libavcodec57 \
  libavformat57 \
  libavutil55 \
  libcairo2 \
  libgdk-pixbuf2.0-0 \
  libgstreamer-plugins-base1.0-0 \
  libgstreamer1.0-0 libgtk2.0-0 \
  gstreamer1.0-plugins-bad \
  libjpeg8 \
  libpng16-16 \
  libswscale4 \
  libtbb2 \
  libtiff5 \
  libtbb-dev \
  wget \
  unzip

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
RUN \
  dpkg -i nvidia/deb/cuda-repo-l4t-10-0-local-10.0.166_1.0-1_arm64.deb && \  
  apt-key add /var/cuda-repo-10-0-local-10.0.166/*.pub && \
  apt-get update && \
  apt-get install -y cuda-cublas-10-0 cuda-cudart-10-0 cuda-toolkit-10-0 && \
  dpkg --remove cuda-repo-l4t-10-0-local-10.0.166 && \
  dpkg -P cuda-repo-l4t-10-0-local-10.0.166 && \
  rm nvidia/deb/cuda-repo-l4t-10-0-local-10.0.166_1.0-1_arm64.deb && \
  dpkg -i nvidia/deb/*.deb && \
  tar xjf nvidia/nvidia_drivers.tbz2 -C / && \
  tar xjf nvidia/config.tbz2 -C / --exclude=etc/hosts --exclude=etc/hostname && \
  tar xjf nvidia/nvgstapps.tbz2 -C / && \
  cp /usr/lib/aarch64-linux-gnu/tegra-egl/nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json && \
  echo "/usr/lib/aarch64-linux-gnu/tegra" > /etc/ld.so.conf.d/nvidia-tegra.conf && \
  echo "/usr/lib/aarch64-linux-gnu/tegra-egl" > /etc/ld.so.conf.d/nvidia-tegra-egl.conf && \
  ldconfig && \
  rm -rf nvidia

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
  mkdir wheel && cd wheel && \
  wget -q https://github.com/zrzka/python-wheel-aarch64/releases/download/jetson-nano-1.1/grpcio-1.21.1-cp36-cp36m-linux_aarch64.whl && \
  wget -q https://github.com/zrzka/python-wheel-aarch64/releases/download/jetson-nano-1.1/h5py-2.9.0-cp36-cp36m-linux_aarch64.whl && \
  wget -q https://github.com/zrzka/python-wheel-aarch64/releases/download/jetson-nano-1.1/numpy-1.16.4-cp36-cp36m-linux_aarch64.whl && \
  wget -q https://github.com/zrzka/python-wheel-aarch64/releases/download/jetson-nano-1.1/pyzmq-18.0.1-cp36-cp36m-linux_aarch64.whl && \
  wget -q https://github.com/zrzka/python-wheel-aarch64/releases/download/jetson-nano-1.1/torch-1.1.0-cp36-cp36m-linux_aarch64.whl && \
  # DON'T CHANGE THE ORDER - otherwise pip will fetch sources and will build them again
  pip3 install --no-cache-dir grpcio-1.21.1-cp36-cp36m-linux_aarch64.whl && \
  pip3 install --no-cache-dir numpy-1.16.4-cp36-cp36m-linux_aarch64.whl && \
  pip3 install --no-cache-dir h5py-2.9.0-cp36-cp36m-linux_aarch64.whl && \
  pip3 install --no-cache-dir pyzmq-18.0.1-cp36-cp36m-linux_aarch64.whl && \
  pip3 install --no-cache-dir torch-1.1.0-cp36-cp36m-linux_aarch64.whl && \
  cd .. && rm -rf wheel

# JetBot dependencies
# https://docs.nvidia.com/deeplearning/frameworks/install-tf-xavier/index.html
# https://github.com/NVIDIA-AI-IOT/jetbot/wiki/Software-Setup
RUN \
  apt-get install --no-install-recommends -y zlib1g-dev zip libjpeg8 libhdf5-100 python3-dev git cmake pkg-config python3-pillow && \
  pip3 install --no-cache-dir wheel && \
  pip3 install --no-cache-dir traitlets ipywidgets && \
  pip3 install --no-cache-dir absl-py py-cpuinfo psutil portpicker six mock requests gast astor termcolor tensorflow-estimator && \
  pip3 install --no-cache-dir --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu && \
  pip3 install --no-cache-dir torchvision

# openCV
RUN \
  apt-get install \
  lbzip2 xorg-dev \
  cmake unzip \
  libgtk2.0-dev pkg-config \
  libavcodec-dev \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libdc1394-22-dev -y --no-install-recommends && \
  wget https://github.com/opencv/opencv/archive/4.0.1.zip && \
  unzip 4.0.1.zip && rm 4.0.1.zip && \
  # TODO: Check if libopencv contains same features, so, we can skip compilation phase
  apt-get remove libopencv -y

RUN \
  wget https://github.com/opencv/opencv_contrib/archive/4.0.1.zip -O opencv_modules.4.0.1.zip && \
  unzip opencv_modules.4.0.1.zip && rm opencv_modules.4.0.1.zip

RUN \
  export CUDA_HOME=/usr/local/cuda-10.0/ && \
  export LD_LIBRARY_PATH=${CUDA_HOME}/lib64 && \
  PATH=${CUDA_HOME}/bin:${PATH} && export PATH && \
  mkdir -p opencv-4.0.1/build && cd opencv-4.0.1/build && \
  cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_BUILD_TYPE=RELEASE -D WITH_CUDA=ON -D CUDA_ARCH_BIN="5.3" -D CUDA_ARCH_PTX="" -D WITH_CUBLAS=ON -D ENABLE_FAST_MATH=ON -D ENABLE_NEON=ON -D WITH_LIBV4L=ON -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.0.1/modules -D WITH_QT=OFF -D WITH_OPENGL=OFF -D WITH_GSTREAMER=ON -D WITH_V4L=ON -D CMAKE_INSTALL_PREFIX=/usr/local .. && make -j32 && make install && \
  cp /usr/src/app/opencv-4.0.1/build/bin/opencv_version /usr/src/app/ && \
  cd /usr/src/app/ && rm -rf /usr/src/app/opencv-4.0.1 && \
  rm -rf /usr/src/app/opencv_contrib-4.0.1

# https://www.waveshare.com/wiki/IMX219-160_Camera
RUN \
  wget https://www.waveshare.com/w/upload/e/eb/Camera_overrides.tar.gz && \
  tar zxvf Camera_overrides.tar.gz -C /var/nvidia/nvcam/settings/ && \
  rm -f Camera_overrides.tar.gz

# JetBot
RUN \
  git clone -b v0.3.0 --single-branch --depth 1 https://github.com/NVIDIA-AI-IOT/jetbot.git && \
  cd jetbot && \
  python3 setup.py install
# TODO: Uncomment cleanup
#  cd .. && rm -rf jetbot  

# Development - to be removed
RUN \
  apt-get install -y xinit xterm ssh

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
# COPY --from=builder /usr/local/lib/python3.6 /usr/local/lib/python3.6
#
# nvidia_drivers.tbz2 & config.tbz2 dance
