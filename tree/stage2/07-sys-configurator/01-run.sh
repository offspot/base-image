#!/bin/bash -e

# TODO: offspot-runtime-config>=1.0.0,<1.1
on_chroot << EOF
pip3 install git+https://github.com/offspot/runtime-config.git@initial
EOF

install -m 755 files/offspot-runtime.service       "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl daemon-reload
systemctl enable offspot-runtime.service
EOF
