#!/bin/sh
# WUUK Y0510 https://amzn.to/4dFlKv1
#
# Instructions
#
# Note: If we increase uboot beyond 256k this needs to be adjusted.
# Build thingino firmware, up to make pack_full, or grab full firmware file from github releases

# -- UPDATE --
# There are now 2 versions of this camera. Most use the sc4336p sensor, a few have the sc401ai sensor.
# the script detect the model and install the correct firmware
# ------------

# Copy full thingio image to sd as /thingino-wuuk_y0510_sc401ai.bin and /thingino-wuuk_y0510_sc4336p.bin
# Put this script on sd as /FACTORY/factory_install.sh
# Insert SD card and power on camera, wait about 10 minutes, it will reboot a few times along the way.

# BACKUP
# a backup of original firmware is done in /backup/autoupdate-full.bin
# to restore it : 
# remove autoupdate-full.done
# remove FACTORY dir
# copy it at the root of sdcard

mount -t vfat /dev/mmcblk0p1 /mnt


if [ -d /mnt/backup ]
then
        echo "backup already exist" >> /mnt/backup/log
        umount /mnt
        exit
fi

mkdir /mnt/backup

#extract info
dmesg > /mnt/backup/dmesg.txt
mount > /mnt/backup/mount.txt
lsmod > /mnt/backup/lsmod.txt
ls -l /dev > /mnt/backup/dev.txt
cat /proc/mtd > /mnt/backup/mtd.txt

#backup partition

for partnum in $(seq 0 20)
do
        part=mtd${partnum}
        if [ ! -e /dev/${part} ]
        then
                break
        fi
        cat /dev/${part} > /mnt/backup/${part}.bin
        cat /mnt/backup/${part}.bin >> /mnt/backup/factory.bin
done

if grep sc401ai /mnt/backup/lsmod.txt
then
        echo "sc401ai" > /mnt/backup/model.txt
        update=/mnt/thingino-wuuk_y0310_t31x_sc401ai_ssv6158.bin
else
	echo "Wrong sensor found" > /mnt/backup/log.txt
        umount /mnt
	exit
fi
sync

if [ ! -f $update ]
then
	echo "Missing update file, aborting" >> /mnt/backup/log.txt
        umount /mnt
	exit
fi

cp $update /mnt/autoupdate-full.bin

echo "Extracing uboot"
dd if=/mnt/autoupdate-full.bin of=/mnt/u-boot-t31x.bin bs=1k count=256

if [ -f /mnt/u-boot-t31x.bin ] && [ -f /mnt/autoupdate-full.bin ]
then
	rm -f /mnt/autoupdate-full.done
        #flash new bootloader
        #it will check the sdcard for autoupdate-full.bin file
        #and flash the whole flash with it
        #if autoupdate-full.done do not exist
	echo "Flashing uboot"
	flashcp /mnt/u-boot-t31x.bin /dev/mtd0
	echo "Rebooting"
        umount /mnt
	reboot
else
	echo "Files missing, not flashing" >> /mnt/backup/log
        umount /mnt
fi
