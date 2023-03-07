#!/bin/bash -e

on_chroot << EOF
# pip3 install https://github.com/offspot/runtime-config/archive/refs/tags/v1.2.0.zip
pip3 install offspot-runtime-config==1.2.0
EOF

install -m 755 files/offspot-runtime.service       "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl daemon-reload
systemctl enable offspot-runtime.service
EOF
