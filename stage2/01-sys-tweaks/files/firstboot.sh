#!/bin/bash

# Resize /data/ partition
DATA=$(findmnt /data -o source -n)
umount /data
parted /dev/mmcblk0 resizepart 3 -- -1s
partprobe /dev/mmcblk0
e2fsck -f -y $DATA
resize2fs $DATA
mount -a

# Disable firstboot script
mv /boot/firstboot.sh /boot/firstboot.sh.done

# Run OLIP Deploy
wget https://gitlab.com/bibliosansfrontieres/tm/nokea-deploy/-/raw/master/go.sh --quiet -O- | bash -