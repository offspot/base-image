#!/bin/bash -e

on_chroot << EOF
pip3 install offspot-runtime-config==1.0.0
EOF

install -m 755 files/offspot-runtime.service       "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl daemon-reload
systemctl enable offspot-runtime.service
EOF
