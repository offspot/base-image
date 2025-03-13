#!/bin/bash -e

on_chroot << EOF
python3 -m venv /usr/local/offspot-python
# /usr/local/offspot-python/bin/pip install https://github.com/offspot/offspot-config/archive/refs/heads/main.zip
/usr/local/offspot-python/bin/pip install offspot-config==2.5.1
EOF

install -m 755 files/offspot-runtime.service       "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl daemon-reload
systemctl enable offspot-runtime.service
EOF
