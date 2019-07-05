# Jetson Nano I2S audio

> **Linux is required.**

You can use VMware Fusion & Linux if you're on macOS. Tested, I did it in this way.

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

## I2S4 PINs

* 7 - `AUDIO_MCLK`
* 12 - `I2S_4_SCLK`
* 35 - `I2S_4_LRCK`
* 38 - `I2S_4_SDIN`
* 40 - `I2S_4_SDOUT`

### Sample wiring

[Adafruit MAX98357 I2S Class-D Mono Amplifier](https://learn.adafruit.com/adafruit-max98357-i2s-class-d-mono-amp/overview):

* `LRC` -> pin 35
* `BCLK` -> pin 12
* `DIN` -> pin 40
* `GND` -> pin 6, 9, 14, 20, 25, 30, 34, 39
* `Vin` -> pin 2, 4

## Audio routing for volume control

Route `ADMAIF1` to `MVC` and then to `I2S4`:

```sh
amixer -c tegrasndt210ref cset name='I2S4 Mux' MVC1
amixer -c tegrasndt210ref cset name='MVC1 Mux' ADMAIF1
```

Set volume (0 - 16,000):

```sh
amixer -c tegrasndt210ref cset name='MVC1 Vol' 12000
```

Visit [Rasperry Pi compatible I2S sound card](https://devtalk.nvidia.com/default/topic/1051993/rasperry-pi-compatible-i2s-sound-card/)
topic for more details (or PulseAudio guide).

## Test

### WAV

```sh
aplay -D hw:tegrasndt210ref,0 test.wav
```

### MP3

```sh
apt-get install sox libsox-fmt-all
AUDIODEV=hw:tegrasndt210ref,0 play test.mp3
```

## Speaker popping

There’s a small problem with this setup - speaker pops just before & after the playback. This is covered by the
[Pi I2S Tweaks](https://learn.adafruit.com/adafruit-max98357-i2s-class-d-mono-amp/pi-i2s-tweaks) page.

Unfortunately, didn’t have time to test these tweaks yet.
