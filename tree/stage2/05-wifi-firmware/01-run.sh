#!/bin/bash -e

# add all optional WiFi firmwares
FIRMWARES_URL=https://drive.offspot.it/wifi-firmwares
FIRMWARES_DIR="${ROOTFS_DIR}/lib/firmware/cypress/"
curl -sL --remote-name --create-dirs --output-dir "${FIRMWARES_DIR}" "${FIRMWARES_URL}/brcmfmac43455-sdio.bin_2021-11-30_minimal"                    # brcm43455    supports-19_2021-11-30
curl -sL --remote-name --create-dirs --output-dir "${FIRMWARES_DIR}" "${FIRMWARES_URL}/brcmfmac43455-sdio.bin_2021-10-05_3rd-trial-minimal"          # brcm43455    supports-24_2021-10-05_noap+sta
curl -sL --remote-name --create-dirs --output-dir "${FIRMWARES_DIR}" "${FIRMWARES_URL}/brcmfmac43455-sdio.clm_blob_2021-11-17_rpi"                   # brcm43455    supports-19_2021-11-30, supports-24_2021-10-05_noap+sta
curl -sL --remote-name --create-dirs --output-dir "${FIRMWARES_DIR}" "${FIRMWARES_URL}/brcmfmac43455-sdio.bin_2015-03-01_7.45.18.0_ub19.10.1"        # brcm43455    supports-32_2015-03-01_unreliable
curl -sL --remote-name --create-dirs --output-dir "${FIRMWARES_DIR}" "${FIRMWARES_URL}/brcmfmac43455-sdio.clm_blob_2018-02-26_rpi"                   # brcm43455    supports-32_2015-03-01_unreliable
curl -sL --remote-name --create-dirs --output-dir "${FIRMWARES_DIR}" "${FIRMWARES_URL}/brcmfmac43430-sdio.bin_2018-09-11_7.45.98.65"                 # brcm43430    supports-30_2018-09-28
curl -sL --remote-name --create-dirs --output-dir "${FIRMWARES_DIR}" "${FIRMWARES_URL}/brcmfmac43430-sdio.clm_blob_2018-09-11_7.45.98.65"            # brcm43430    supports-30_2018-09-28

on_chroot << EOF
# move raspios firmwares to dedicated files
cp -L -p /lib/firmware/cypress/cyfmac43430-sdio.bin /lib/firmware/cypress/cyfmac43430-sdio.bin_raspios
cp -L -p /lib/firmware/cypress/cyfmac43430-sdio.clm_blob /lib/firmware/cypress/cyfmac43430-sdio.clm_blob_raspios
cp -L -p /lib/firmware/cypress/cyfmac43455-sdio.bin /lib/firmware/cypress/cyfmac43455-sdio.bin_raspios
cp -L -p /lib/firmware/cypress/cyfmac43455-sdio.clm_blob /lib/firmware/cypress/cyfmac43455-sdio.clm_blob_raspios

# set the best know ones as default (saves a reboot on first boot)
ln -sf /lib/firmware/cypress/brcmfmac43455-sdio.bin_2021-10-05_3rd-trial-minimal /lib/firmware/cypress/cyfmac43455-sdio.bin
ln -sf /lib/firmware/cypress/brcmfmac43455-sdio.clm_blob_2021-11-17_rpi /lib/firmware/cypress/cyfmac43455-sdio.clm_blob

ln -sf /lib/firmware/cypress/brcmfmac43430-sdio.bin_2018-09-11_7.45.98.65 /lib/firmware/cypress/cyfmac43430-sdio.bin
ln -sf /lib/firmware/cypress/brcmfmac43430-sdio.clm_blob_2018-09-11_7.45.98.65 /lib/firmware/cypress/cyfmac43430-sdio.clm_blob
EOF
