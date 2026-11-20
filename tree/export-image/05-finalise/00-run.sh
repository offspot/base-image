#!/bin/bash -e

rm -rf "${ROOTFS_DIR}"/var/lib/apt/lists/*
mkdir -p "${ROOTFS_DIR}/var/lib/apt/lists/partial"

rm -f "${ROOTFS_DIR}"/var/cache/apt/*.bin
rm -rf "${ROOTFS_DIR}"/var/cache/apt/archives/*
mkdir -p "${ROOTFS_DIR}/var/cache/apt/archives/partial"
