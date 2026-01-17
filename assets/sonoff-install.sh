#!/bin/sh

# Make backup of existing flash
mkdir -p /mnt/sdcard/backup
for partnum in $(seq 0 20)
do
        part=mtd${partnum}
        if [ ! -e /dev/${part} ]
        then
                break
        fi
        cat /dev/${part} > /mnt/sdcard/backup/${part}.bin
        cat /mnt/sdcard/backup/${part}.bin >> /mnt/sdcard/backup/factory.bin
done

# Grab uboot from image
dd if=/mnt/sdcard/autoupdate-full.bin bs=1k count=256 of=/mnt/sdcard/uboot.bin

# flash uboot
flashcp /mnt/sdcard/uboot.bin /dev/mtd0

# reboot and let uboot finish the job
reboot

