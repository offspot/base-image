# base-image

A raspiOS-like image to use as *master* for both Kiwix Offspot and OLIP through the use of [`image-creator`](https://github.com/offspot/image-creator).

[![release](https://img.shields.io/github/v/tag/offspot/base-image?label=latest%20release&sort=semver)](https://drive.offspot.it/base/)
[![CodeFactor](https://www.codefactor.io/repository/github/offspot/base-image/badge)](https://www.codefactor.io/repository/github/offspot/base-image)
[![Build Status](https://github.com/offspot/base-image/actions/workflows/build-and-upload.yml/badge.svg?branch=main)](https://github.com/offspot/base-image/actions/workflows/build-and-upload.yml?query=branch%3Amain)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)


## Scope

This produces a raspiOS-like image that will, in a compatible device:

- Setup a (configurable) WiFi Access Point
- Setup ethernet networking (accoding to configuration)
- Setup a docker-compose project

Our **target is all Raspberry Pi 3 models and newer**. Currently: `3A+`, `3B`, `3B+`, `4B`, `400`, `Zero 2 W`.

## Usage

Requirements: **docker**, **python3**. It is possible to build the image without docker (`--no-docker`) but requires specific host system and requirements (see pi-gen)

```
./builder.py --help
```

## Testing Images

Releases are available from https://drive.offspot.it/base/. Test builds are uploades to S3. Links are available in the run's details.

Regular tests can be done via [dockerpi](/lukechilds/dockerpi)

```sh
docker run -it -v $(pwd)/offspot-base.img:/sdcard/filesystem.img lukechilds/dockerpi pi3
```

Don't validate an image without testing on actual hardware by [flashing the Image on a microSD card](https://github.com/raspberrypi/rpi-imager).

## Troubleshooting

This tool mainly prepares a pi-gen custom build so checking the [troubleshooting](https://github.com/RPi-Distro/pi-gen/blob/master/README.md#troubleshooting) section there should be a first in case of any trouble. You should also be familiar with its [README](https://github.com/RPi-Distro/pi-gen/blob/master/README.md).

## Using non-standard hardware

We only provide support for our fixed targets list and scenarios. That said, it's a raspiOS system so you should be able to adapt it easily.

- Pi Compute Module matching a supported Model with WiFi should work directly.
- No WiFi scenario is not supported. You'll need to tweak the runtime-config script so it doesn't start `hostapd`.
- Using additional WiFi interfaces is possible (as client or as AP). If chipset is not supported, its driver must be installed.
- Non-arm would require tweaking the tree and the script to use regular debian sources instead of raspbian.
- 32b ARM (Pi 0/1/2) can work. Use the `--arch=armhf` flag of the builder. In the running system, remove docker and its source-list then reinstall it from raspbian repo.

```sh
apt-get remove docker-ce docker-ce-cli containerd.io docker-compose-plugin runc
rm /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install docker.io docker-compose
```

Please, [Open a ticket](https://github.com/offspot/base-image/issues/new) explaining what you're trying to achieve and why. We may be able to provide directions. 