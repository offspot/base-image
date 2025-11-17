#!/bin/bash -e

on_chroot << EOF
python3 -m venv /usr/local/offspot-python
#/usr/local/offspot-python/bin/pip install https://github.com/offspot/offspot-config/archive/refs/heads/main.zip
/usr/local/offspot-python/bin/pip install offspot-config==2.7.1
EOF

install -m 755 files/offspot-runtime.service       "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl daemon-reload
systemctl enable offspot-runtime.service
EOF

on_chroot << EOF
python3 -m venv /usr/local/mekhenet-python
/usr/local/mekhenet-python/bin/pip install fastapi==0.121.0 uvicorn==0.38.0
EOF

install -m 755 files/mekhenet.py       "${ROOTFS_DIR}/usr/local/mekhenet-python/lib/python3.13/site-packages/"
install -m 755 files/mekhenet.service       "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl daemon-reload
systemctl enable mekhenet.service
EOF
