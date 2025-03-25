# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.1] - 2025-03-25

### Changed

- Inter-services dependencies fix for network scenarios
- Fixed systemd unit files permissions #69
- Using offspot-config 2.5.3 (iptables-restore service detection fix)

## [1.3.0] - 2025-03-13

### Changed

- WiFi firmwares are downloaded at build time instead of being copied from repo
- Based on pi-gen `2024-03-15-raspios-bookworm`
- Using offspot-config 2.5.1 (no runtime changes)
- Fixed race-condition between balena and iptables-restore

## [1.2.1] - 2024-04-04

### Changed

- Check part3 filesystem before and after resize2fs to ensure it succeeeds #63
- Use force (-f) for resize2fs

## [1.2.0]

### Added

- WiFi firmware management with additional firmwares on disk

### Changed

- Using offspot-config 1.10.0 with firmware support

## [1.1.1]

### Added

- `docker` command forwarding cli to balena-engine to ease dev and debug

### Changed

- Using offspot-config 1.5.0
- Fixed docker-images-loader to depend on balena.service

## [1.1.0] - 2023-12-08

### Added

- Release image is now published both as .img and xz-compressed .img.xz

### Changed

- Updated to 2023-12-05-raspios-buster
- Added support for hardware clock.
- Using new `offspot-config` (1.4.6) package (which includes runtime_config)
- OCI stack changed from Docker to BalenaEngine

## [1.0.1] - 2023-03-07

### Changed

- Fixed disabling auto-spoof failing due to lack of return code (runtime-config 1.2.0)

## [1.0.0] - 2023-02-09

* Based on 2022-09-06-raspios-bullseye's pi-gen
