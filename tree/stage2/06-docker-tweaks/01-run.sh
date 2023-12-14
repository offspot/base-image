#!/bin/bash -e

# download/install balena-engine using static bin
curl -sL https://github.com/balena-os/balena-engine/releases/download/v20.10.41/balena-engine-v20.10.41-arm64.tar.gz | tar xzv -C ${ROOTFS_DIR}/usr/local/bin/ --strip-components=1
# fake docker bin redirecting to balena (helps with dev)
install -m 755 files/docker "${ROOTFS_DIR}/usr/local/bin/"

# download/install docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-aarch64" -o ${ROOTFS_DIR}/usr/local/bin/docker-compose
chmod +x ${ROOTFS_DIR}/usr/local/bin/docker-compose

# instruct docker to work off the loop-device and use a low-disk-space-usage logger
mkdir -p ${ROOTFS_DIR}/etc/balena-engine
printf '{"data-root": "/data/docker", "log-driver": "journald"}' > ${ROOTFS_DIR}/etc/balena-engine/daemon.json

# add docker group to main user
on_chroot << EOF
groupadd balena-engine
adduser $FIRST_USER_NAME balena-engine
EOF

# install balena service
install -m 777 files/balena.service "${ROOTFS_DIR}/etc/systemd/system/"
install -m 777 files/balena.socket "${ROOTFS_DIR}/etc/systemd/system/"

# install the image loading service
install -m 755 files/docker-images-loader.py "${ROOTFS_DIR}/usr/sbin/"
install -m 777 files/docker-images-loader.service "${ROOTFS_DIR}/etc/systemd/system/"

# install docker compose stub and service
mkdir -p ${ROOTFS_DIR}/etc/docker
install -m 755 files/compose.yml "${ROOTFS_DIR}/etc/docker/"
install -m 777 files/docker-compose.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl daemon-reload
systemctl enable balena.socket
systemctl enable balena.service
systemctl enable docker-images-loader.service
systemctl enable docker-compose.service
EOF
