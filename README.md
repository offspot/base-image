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

Download image at : https://drop.bsf-intranet.org/2021-11-26-ideascube-lite.zip