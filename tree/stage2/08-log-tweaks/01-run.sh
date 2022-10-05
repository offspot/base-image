
# journald drop-in to set journal to volatile
mkdir -p ${ROOTFS_DIR}/etc/systemd/journald.conf.d
install -m 644 files/00-offspot-volatile.conf		"${ROOTFS_DIR}/etc/systemd/journald.conf.d/"

# custom motd with log setup details
install -m 644 files/motd		"${ROOTFS_DIR}/etc/"
install -m 644 files/offspot-logs		"${ROOTFS_DIR}/etc/"
