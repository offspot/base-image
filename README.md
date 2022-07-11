# base-image

A Raspberry-targetting image to use as *master* for both Kiwix Offspot and OLIP through the use of [`image-creator`](https://github.com/offspot/image-creator).

[![release](https://img.shields.io/github/v/tag/offspot/base-image?label=latest%20release&sort=semver)](https://drive.offspot.it/base/)
[![CodeFactor](https://www.codefactor.io/repository/github/offspot/base-image/badge)](https://www.codefactor.io/repository/github/offspot/base-image)
[![Build Status](https://github.com/offspot/base-image/actions/workflows/build-and-upload.yml/badge.svg?branch=main)](https://github.com/offspot/base-image/actions/workflows/build-and-upload.yml?query=branch%3Amain)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Scope

- Based off [RaspiOS Lite](https://www.raspberrypi.com/software/).
- Built using [`pi-gen`](https://github.com/RPi-Distro/pi-gen).
- Using [docker-ce](https://docs.docker.com/engine/) to host applications (engine data in `/data/docker`)
- Applications data expected on `/data`
- Limited features to what's essential/common/stable
 - 3 Partitions: boot, root and data (`exFAT`)
 - Network configuration (dhcp on eth0, fixed on wlan0)
 - Hotspot with dnsmasq and hostAPd
 - Internet sharing from eth0 to wlan0
 - VPN client with [tinc](https://tinc-vpn.org/).
 - dev/maint non-daemon tools: vim, curl, jq, screen, git, tmux)
 - Custom/specified WiFi firmware
- [Limited writes](https://github.com/RaspAP/raspap-tools/blob/main/raspian_min_write.sh) on root partition
- Boot-time script to toggle features and configuration using a custom `/boot/config.json` file.
- Captive portal *server* managed by Captive-portal APP via a socket

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
