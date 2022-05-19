# OLIP base image for Raspberry pi

Build with 

```
build-docker.sh
```
with values from `config` file

Example : 

```
IMG_NAME=ideascube
STAGE_LIST="stage0 stage1 stage2"
FIRST_USER_NAME="ideascube"
FIRST_USER_PASS="ideascube"
ENABLE_SSH=1
PUBKEY_SSH_FIRST_USER=""
TIMEZONE_DEFAULT="Europe/Paris"
TARGET_HOSTNAME="ideascube"
DEPLOY_ZIP="1"
USE_QCOW2="0"
```

More information : https://github.com/RPi-Distro/pi-gen#config

Download image at : 
* Old stable : https://drop.bsf-intranet.org/image_2021-12-15-ideascube-lite.zip
* Last update : https://drop.bsf-intranet.org/image_2022-05-19-ideascube-lite.zip
