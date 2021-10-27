# base-image

A Raspberry-targetting image to use as *master* for both Kiwix Offspot and OLIP through the use of [`image-creator`](https://github.com/offspot/image-creator).

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
