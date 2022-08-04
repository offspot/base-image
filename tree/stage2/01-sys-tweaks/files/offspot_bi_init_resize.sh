#!/bin/sh

# adaptation of raspi-config's init_resize.sh script that is used
# as an init on first on-device boot to resize root partition to fill sd size.
#
# this version does not resize root partition (its size is fixed) but takes care of
# our third “data” partition.
# this partition being exfat, it can't be resized and is recreated, passing its
# content to root partition (in /tmp) temporarily so it's not lost.
#
# /!\ there should not be any substantial data on /data partition at this stage
# this “backup” feature is complimentary.
# Any tool using this base image should recreate the /data partition to its wanted
# size and thus remove the /data/master_fs flag file that enables this to run.
#
# https://github.com/RPi-Distro/raspi-config/blob/master/usr/lib/raspi-config/init_resize.sh

reboot_pi () {
  umount /boot
  umount /data
  mount / -o remount,ro
  sync
  reboot -f
  sleep 5
  exit 0
}

check_commands () {
  if ! command -v whiptail > /dev/null; then
      echo "whiptail not found"
      sleep 5
      return 1
  fi
  for COMMAND in grep cut sed parted fdisk findmnt; do
    if ! command -v $COMMAND > /dev/null; then
      FAIL_REASON="$COMMAND not found"
      return 1
    fi
  done
  return 0
}

get_variables () {
	ROOT_PART_DEV=$(findmnt / -o source -n)
	ROOT_PART_NAME=$(echo "$ROOT_PART_DEV" | cut -d "/" -f 3)
	ROOT_DEV_NAME=$(echo /sys/block/*/"${ROOT_PART_NAME}" | cut -d "/" -f 4)
	ROOT_DEV="/dev/${ROOT_DEV_NAME}"
	ROOT_PART_NUM=$(cat "/sys/block/${ROOT_DEV_NAME}/${ROOT_PART_NAME}/partition")

	BOOT_PART_DEV=$(findmnt /boot -o source -n)
	BOOT_PART_NAME=$(echo "$BOOT_PART_DEV" | cut -d "/" -f 3)
	BOOT_DEV_NAME=$(echo /sys/block/*/"${BOOT_PART_NAME}" | cut -d "/" -f 4)
	BOOT_PART_NUM=$(cat "/sys/block/${BOOT_DEV_NAME}/${BOOT_PART_NAME}/partition")

	DATA_PART_DEV=$(findmnt /data -o source -n)
	DATA_PART_NAME=$(echo "$DATA_PART_DEV" | cut -d "/" -f 3)
	DATA_DEV_NAME=$(echo /sys/block/*/"${DATA_PART_NAME}" | cut -d "/" -f 4)
	DATA_DEV="/dev/${DATA_DEV_NAME}"
	DATA_PART_NUM=$(cat "/sys/block/${DATA_DEV_NAME}/${DATA_PART_NAME}/partition")

	OLD_DISKID=$(fdisk -l "$ROOT_DEV" | sed -n 's/Disk identifier: 0x\([^ ]*\)/\1/p')

	ROOT_DEV_SIZE=$(cat "/sys/block/${ROOT_DEV_NAME}/size")
	TARGET_END=$((ROOT_DEV_SIZE - 1))

	PARTITION_TABLE=$(parted -m "$ROOT_DEV" unit s print | tr -d 's')

	LAST_PART_NUM=$(echo "$PARTITION_TABLE" | tail -n 1 | cut -d ":" -f 1)

	ROOT_PART_LINE=$(echo "$PARTITION_TABLE" | grep -e "^${ROOT_PART_NUM}:")
	ROOT_PART_START=$(echo "$ROOT_PART_LINE" | cut -d ":" -f 2)
	ROOT_PART_END=$(echo "$ROOT_PART_LINE" | cut -d ":" -f 3)

	DATA_PART_LINE=$(echo "$PARTITION_TABLE" | grep -e "^${DATA_PART_NUM}:")
	DATA_PART_START=$(echo "$DATA_PART_LINE" | cut -d ":" -f 2)
	DATA_PART_END=$(echo "$DATA_PART_LINE" | cut -d ":" -f 3)
}

fix_partuuid() {
  mount -o remount,rw "$ROOT_PART_DEV"
  mount -o remount,rw "$BOOT_PART_DEV"
  DISKID="$(tr -dc 'a-f0-9' < /dev/hwrng | dd bs=1 count=8 2>/dev/null)"
  if printf "x\ni\n0x$DISKID\nr\nw\n" | fdisk "$ROOT_DEV" > /dev/null; then
    sed -i "s/${OLD_DISKID}/${DISKID}/g" /etc/fstab
    sed -i "s/${OLD_DISKID}/${DISKID}/" /boot/cmdline.txt
    sync
  fi

  mount -o remount,ro "$ROOT_PART_DEV"
  mount -o remount,ro "$BOOT_PART_DEV"
}

check_variables () {

  if [ "$BOOT_DEV_NAME" != "$ROOT_DEV_NAME" ] || [ "$ROOT_DEV_NAME" != "$DATA_DEV_NAME" ]; then
      FAIL_REASON="Boot, root and data partitions are not all on same device"
      return 1
  fi

  if [ "$DATA_PART_NUM" -ne "$LAST_PART_NUM" ]; then
    FAIL_REASON="Data partition should be last partition"
    return 1
  fi

  if [ "$DATA_PART_END" -gt "$TARGET_END" ]; then
    FAIL_REASON="Data partition runs past the end of device"
    return 1
  fi

  if [ ! -b "$ROOT_DEV" ] || [ ! -b "$ROOT_PART_DEV" ] || [ ! -b "$DATA_PART_DEV" ] || [ ! -b "$BOOT_PART_DEV" ] ; then
    FAIL_REASON="Could not determine partitions"
    return 1
  fi
}

main () {
  get_variables

  if ! check_variables; then
    return 1
  fi

  if [ "$DATA_PART_END" -eq "$TARGET_END" ]; then
    reboot_pi
  fi

  # dump /data content (should not be large) into /tmp
  mount / -o remount,rw
  mount /data -o remount,ro
  tar -c -f /mnt/data_part.tar --exclude "/data/master_fs" /data
  sync
  umount /data

  # resize partition (not filesystem)
  if ! parted -m "$ROOT_DEV" u s resizepart "$DATA_PART_NUM" "$TARGET_END"; then
    FAIL_REASON="Data partition resize failed"
    return 1
  fi

  # recreate filesystem (can't rezise exFAT)
  mkfs.exfat -L data "$DATA_PART_DEV" > /dev/null

  # restore files onto data partition
  mount /data -o rw
  tar -C /data -x --strip-components 1 -f /mnt/data_part.tar
  rm -f /mnt/data_part.tar
  sync
  mount / -o remount,ro
  mount /data -o remount,ro

  fix_partuuid

  return 0
}

mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmp /run
mkdir -p /run/systemd

mount /boot
mount / -o remount,ro
mount /data -o ro

# remove itself from boot, regardless of whether we're resizing or not
sed -i 's| init=/usr/sbin/offspot_bi_init_resize\.sh||' /boot/cmdline.txt
sed -i 's| sdhci\.debug_quirks2=4||' /boot/cmdline.txt

if ! grep -q splash /boot/cmdline.txt; then
  sed -i "s/ quiet//g" /boot/cmdline.txt
fi
sync
mount /boot -o remount,ro

# skip resizing process if not on a declared master fs
if [ ! -f /data/master_fs ] ; then
    reboot_pi
fi

if ! check_commands; then
  reboot_pi
fi

if main; then
  whiptail --infobox "Recreated data filesystem. Rebooting in 5 seconds..." 20 60
  sleep 5
else
  whiptail --msgbox "Could not recreate data filesystem Rebooting...\n${FAIL_REASON}" 20 60
  sleep 5
fi

reboot_pi
