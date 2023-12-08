# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
