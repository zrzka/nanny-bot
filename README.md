# Nanny bot

Check the [Building a nanny bot](https://forums.balena.io/t/building-a-nanny-bot/10052) topic
for more information & progress of this project.

It's a weekend project (slow progress) and highly experimental one.

## Jetbot

For now, this project demonstrates how to run the NVIDIA's Jetbot on balenaCloud device.

**NOTE** The resulting image size is ~10GB. This is due to the fact that it's not
optimised yet and it still contains all the gcc, g++, nvcc, ... tools.

### Step 1 - JetPack SDK

* Download [NVIDIA SDK Manager](https://developer.nvidia.com/embedded/jetpack) (JetPack **4.2**)
  * You have to use Ubuntu for example & VMware Fusion if you're on macOS
* Run the SDK manager, sign in and download all required packages for the Jetson Nano
  * Files will be stored in the `~/Downloads/nvidia/sdkm_downloads` folder
* Run `./prepare.sh` script
  * It creates the `nvidia` folder with all required files
  * It removes `/nvidia` line from the `.gitignore` file [1]

[1] `.gitignore` file must be updated otherwise `balena push` won't push the `nvidia` folder.

This is how the `nvidia` folder should look like:

```text
nvidia/
├── config.tbz2
├── deb
│   ├── cuda-repo-l4t-10-0-local-10.0.166_1.0-1_arm64.deb
│   ├── graphsurgeon-tf_5.0.6-1+cuda10.0_arm64.deb
│   ├── libcudnn7-dev_7.3.1.28-1+cuda10.0_arm64.deb
│   ├── libcudnn7-doc_7.3.1.28-1+cuda10.0_arm64.deb
│   ├── libcudnn7_7.3.1.28-1+cuda10.0_arm64.deb
│   ├── libnvinfer-dev_5.0.6-1+cuda10.0_arm64.deb
│   ├── libnvinfer-samples_5.0.6-1+cuda10.0_all.deb
│   ├── libnvinfer5_5.0.6-1+cuda10.0_arm64.deb
│   ├── libopencv-dev_3.3.1-2-g31ccdfe11_arm64.deb
│   ├── libopencv-python_3.3.1-2-g31ccdfe11_arm64.deb
│   ├── libopencv-samples_3.3.1-2-g31ccdfe11_arm64.deb
│   ├── libopencv_3.3.1-2-g31ccdfe11_arm64.deb
│   ├── libvisionworks-repo_1.6.0.500n_arm64.deb
│   ├── libvisionworks-sfm-repo_0.90.4_arm64.deb
│   ├── libvisionworks-tracking-repo_0.88.2_arm64.deb
│   ├── python3-libnvinfer-dev_5.0.6-1+cuda10.0_arm64.deb
│   ├── python3-libnvinfer_5.0.6-1+cuda10.0_arm64.deb
│   ├── tensorrt_5.0.6.3-1+cuda10.0_arm64.deb
│   └── uff-converter-tf_5.0.6-1+cuda10.0_arm64.deb
├── nvgstapps.tbz2
└── nvidia_drivers.tbz2
```

### Step 2 - Build & deploy

```sh
balena push <appName>
```

Replace `<appName>` with your Jetson Nano application name on the balenaCloud.
