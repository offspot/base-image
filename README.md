# Base image Creator

A Raspberry-targetting image to use as *base* for both Kiwix Offspot
and OLIP through the use of
[`image-creator`](https://github.com/offspot/image-creator). Based on
[pi-gen](https://github.com/RPi-Distro/pi-gen).

[![CodeFactor](https://www.codefactor.io/repository/github/offspot/base-image/badge)](https://www.codefactor.io/repository/github/offspot/base-image)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Scope

- Based off [RaspiOS Lite](https://www.raspberrypi.com/software/).
- Built using [`pi-gen`](https://github.com/RPi-Distro/pi-gen).
- Using [balenaEngine](https://www.balena.io/engine/) to host applications (engine data in `/data/balena`)
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

## Troubleshooting

If you have a problem during the base image creation; check first if
help is already available at [pi-gen](https://github.com/RPi-Distro/pi-gen):
- Read [pi-gen' README](https://github.com/RPi-Distro/pi-gen/blob/master/README.md#troubleshooting)
up to then end.
- Search in the [pi-gen known issues](https://github.com/RPi-Distro/pi-gen/issues?q=is%3Aissue+).

If you are still stuck, then [open a
ticket](https://github.com/offspot/base-image/issues) in our bug
tracker.