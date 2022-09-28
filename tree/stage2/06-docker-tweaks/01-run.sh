#!/bin/bash -e

# instruct docker to work off the loop-device and use a low-disk-space-usage logger
mkdir -p ${ROOTFS_DIR}/etc/docker
printf '{"data-root": "/data/virtual/docker", "log-driver": "journald"}' > ${ROOTFS_DIR}/etc/docker/daemon.json

# instruct containerd to work off the loop-device as well
sed -i -E 's/^#root\s=.+/root = "\/data\/virtual\/containerd"/' ${ROOTFS_DIR}/etc/containerd/config.toml

# add docker group to main user
on_chroot << EOF
adduser $FIRST_USER_NAME docker
EOF

# install the image loading service
install -m 755 files/docker-images-loader.py "${ROOTFS_DIR}/usr/sbin/"
install -m 777 files/docker-images-loader.service "${ROOTFS_DIR}/etc/systemd/system/"
# install docker compose stub and service
install -m 755 files/compose.yml "${ROOTFS_DIR}/etc/docker/"
install -m 777 files/docker-compose.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl daemon-reload
systemctl enable docker-images-loader.service
systemctl enable docker-compose.service
EOF
