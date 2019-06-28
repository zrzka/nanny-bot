# Jetson Nano I2S audio

> **Linux is required.**

You can use VMware Fusion & Ubuntu if you're on macOS. It's tested, I did it in this way.

## Patch & flash DTB

### Jetson Nano recovery mode

* [Jetson Nano Developer Kit - User Guide](https://developer.nvidia.com/embedded/dlc/jetson-nano-dev-kit-user-guide)
* You need 5V/4A adapter (2.1mm inner diameter, 5.5mm outer diameter)
* Force recovery mode
  * J40 - connect pin 3 & 4 (see page 6 & 7)
* Tell Nano to use power adapter
  * J48 - connect pins (see page 8)
* Connect Jetson Nano to your computer (micro USB)
* Connect power adapter

### Patch & flash

* Extract `Jetson-210_Linux_R32.1.0_aarch64.tbz2`
* Note path to the `Linux_for_Tegra` folder

```sh
gpio-to-i2s/patch-and-flash.sh path/to/Linux_for_Tegra
```

* Answer `Y`/`y` if you'd like to flash it

## PINs

* 7 - `AUDIO_MCLK`
* 12 - `I2S_4_SCLK`
* 35 - `I2S_4_LRCK`
* 38 - `I2S_4_SDIN`
* 40 - `I2S_4_SDOUT`

## Test

```sh
aplay -D plughw:CARD=tegrasndt210ref,DEV=0 test.wav
```
