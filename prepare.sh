#!/usr/bin/env bash

set -e

SDKM_DLPATH=${1:-~/Downloads/nvidia/sdkm_downloads}
FILE_LIST=$(cat <<-END
  cuda-repo-l4t-10-0-local-10.0.166_1.0-1_arm64.deb
  libnvinfer5_5.0.6-1+cuda10.0_arm64.deb
  libvisionworks-tracking-repo_0.88.2_arm64.deb
  graphsurgeon-tf_5.0.6-1+cuda10.0_arm64.deb
  libopencv-dev_3.3.1-2-g31ccdfe11_arm64.deb
  python3-libnvinfer-dev_5.0.6-1+cuda10.0_arm64.deb
  libcudnn7-dev_7.3.1.28-1+cuda10.0_arm64.deb
  libopencv-python_3.3.1-2-g31ccdfe11_arm64.deb
  python3-libnvinfer_5.0.6-1+cuda10.0_arm64.deb
  libcudnn7-doc_7.3.1.28-1+cuda10.0_arm64.deb
  libopencv-samples_3.3.1-2-g31ccdfe11_arm64.deb
  tensorrt_5.0.6.3-1+cuda10.0_arm64.deb
  libcudnn7_7.3.1.28-1+cuda10.0_arm64.deb
  libopencv_3.3.1-2-g31ccdfe11_arm64.deb
  uff-converter-tf_5.0.6-1+cuda10.0_arm64.deb
  libnvinfer-dev_5.0.6-1+cuda10.0_arm64.deb
  libvisionworks-repo_1.6.0.500n_arm64.deb
  libnvinfer-samples_5.0.6-1+cuda10.0_all.deb
  libvisionworks-sfm-repo_0.90.4_arm64.deb
END
)

if [ ! -d "${SDKM_DLPATH}" ]; then
    echo "NVIDIA SDK download folder doesn't exist: ${SDKM_DLPATH}"
    echo "Visit https://developer.nvidia.com/embedded/jetpack & download NVIDIA SDK Manager 4.2"
    echo "Create an account and let the SDK Manager download Jetson Nano files"
    exit 1
fi

if [ ! -f "${SDKM_DLPATH}/Jetson-210_Linux_R32.1.0_aarch64.tbz2" ]; then
    echo "L4T files do not exist in the ${SDKM_DLPATH} folder!"
    exit 1
fi

if [ -d ./tmp ]; then
  echo "Removing the old temporary folder ..."
  rm -rf ./tmp
fi

echo "Creating temporary folder ..."
mkdir -p ./tmp/deb

echo "Copying JetPack SDK DEB files ..."
for FILE in $FILE_LIST; do
  cp "${SDKM_DLPATH}/${FILE}" ./tmp/deb
done

echo "Extracting configuration & NVIDIA drivers ..."
tar xjf "${SDKM_DLPATH}/Jetson-210_Linux_R32.1.0_aarch64.tbz2" -C ./tmp/
mv ./tmp/Linux_for_Tegra/nv_tegra/config.tbz2 ./tmp/
mv ./tmp/Linux_for_Tegra/nv_tegra/nvidia_drivers.tbz2 ./tmp/
rm -rf ./tmp/Linux_for_Tegra

if [ -d ./nvidia ]; then
  echo "Removing the old nvidia folder ..."
  rm -rf ./nvidia
fi
echo "Renaming temporary folder to nvidia ..."
mv tmp nvidia

echo "Removing .gitignore in the project root ..."
if [ -f ./.gitignore ]; then
  rm -f ./.gitignore
fi

echo "Done. You may now run: balena push DEVICE_IP"
echo
echo "********************************************************************************"
echo "* DO NOT COMMIT removed .gitignore file & the nvidia folder                    *"
echo "********************************************************************************"
