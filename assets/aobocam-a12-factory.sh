#!/bin/sh
# Aobocam A12: https://amzn.com/dp/B0DHL7MKBN
# 
# *IMPORTANT*: This script installs thingino *ONLY* on the factory firmware.
#
# Instructions:
# Copy full thingino image ("thingino-aobocam_a12_t23dl_jxh63p_txw901u.bin") as "autoupdate-full.bin"
# Copy this script as "/t23_prod_eth_test" in the root of the SD card.
# Copy the binary "busybox-mipsel-linux-gnu" as "/thingino/busybox" in the SD.
# Insert SD card and power on camera, wait about 10 minutes, it will reboot a few times along the way.

# Backup:
# A backup of the original firmware is done in /backup/factory.bin
# To restore it :
#  - Rename "/backup/factory.bin" to "autoupdate-full.bin" 
#  - Copy it to at the root of an empty SD card
#  - Insert in the camera, boot it and wait few minutes

echo "THINGINO INSTALLER: see log in /sdcard/thingino/thingino-installer.log"

# Backup firmware
if [ -d /sdcard/backup ]
then
  echo "Backup folder already exists, not flashing" >> /sdcard/thingino/thingino-installer.log
  exit 
fi

echo "Creating backup of the factory firmware" >> /sdcard/thingino/thingino-installer.log
mkdir /sdcard/backup

for partnum in $(seq 0 20)
do
  part=mtd${partnum}
  if [ ! -e /dev/${part} ]
  then
    break
  fi
  cat /dev/${part} > /sdcard/backup/${part}.bin
  cat /sdcard/backup/${part}.bin >> /sdcard/backup/factory.bin
done

# Check prerequisites before flashing
if [ -z "$(ls /sdcard/backup)" ]
then
  echo "Backup failed, not flashing" >> /sdcard/thingino/thingino-installer.log
  exit 1
fi

if [ ! -f /sdcard/autoupdate-full.bin ] || [ ! -f /sdcard/thingino/busybox ]
then
  echo "Installer files missing, not flashing" >> /sdcard/thingino/thingino-installer.log
  exit 1
fi    

# Replace factory busybox with a fully fledged version with "flashcp" applet
mount --bind /sdcard/thingino/busybox /bin/busybox

# Extract and flash bootloader
dd if=/sdcard/autoupdate-full.bin of=/sdcard/u-boot-t23dl.bin bs=1k count=256
if [ -f /sdcard/u-boot-t23dl.bin ]
then
  echo "Flashing uboot ..." >> /sdcard/thingino/thingino-installer.log
  flashcp /sdcard/u-boot-t23dl.bin /dev/mtd0
  echo "Flashed, rebooting" >> /sdcard/thingino/thingino-installer.log
 
  # Clean up 
  rm -f /sdcard/autoupdate-full.done
  rm -f /sdcard/u-boot-t23dl.bin
  rm -f /sdcard/t23_prod_eth_test
  
  # The newly flashed u-boot will automatically detect and flash "autoupdate-full.bin" on reboot
  # (if "autoupdate-full.done do not exist")
  umount /sdcard
  reboot
else
  echo "Couldn't extract u-boot from autoupdate-full.bin, not flashing" >> /sdcard/thingino/thingino-installer.log
fi
