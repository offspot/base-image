#!/bin/bash -e

on_chroot << EOF
# pip3 install https://github.com/offspot/offspot-config/archive/refs/heads/main.zip
pip3 install offspot-config==1.3.0
EOF

install -m 755 files/offspot-runtime.service       "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl daemon-reload
systemctl enable offspot-runtime.service
EOF
