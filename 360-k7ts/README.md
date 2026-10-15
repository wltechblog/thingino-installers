# 360 K7TS

# This image will upgrade your camera from factory firmware to Thingino. Don't try to use this for upgrading afterwards!



# This process IS NOT fully reversible, you may lose your original MAC address in boootenv.

The first step of this installer will create a backup of your factory firmware, which can be used to revert back to the camera if you need to.
The factory firmware file is stored by parition and gzip compressed and will be in 360_BACKUP_XX_XX_XX_XX_XX_XX/
This backup is unique PER CAMERA, so if you don't save it somewhere yourself you won't be able to revert.

The images in the installers are updated once a week, you probably want to do a full upgrade after installing!


# Installation Steps

0. If you want to do backup only, you can change backup_only=1 in the start of initramfs_files/initramfsrun.sh
1. Download the zip file for the camera from this repository
2. Use a sd image burning software such as Rufus or Raspberry Pi Imager to write the image to your sd card (any card 128MB or larger)
4. Power off your camera and insert the sd card, press and hold the reset button when power it on and release it after you see led flashes.
5. Wait around 15 minutes and you should hear the update info from the speaker.
6. If you didn't see the thingino wifi after 10 minutes, or it says something wrong, you can also telnet the ip address of your camera to see why. It will tell ip address by speaker.
7. After setting up the camera in webui, make sure to do a full update to current firmware as the included files are only updated periodically. You can upate via webui in `Tools->Flash Operations` or via ssh using `sysupgrade -f`

# Notes

If you are flashing multiple cameras, you need to copy and store the factory firmware backup files (360_BACKUP_XX_XX_XX_XX_XX_XX/), then use
Your sd image burner to burn a fresh installer each time.

# Reversal Steps

To revert back to the stock firmware:

You can try adding "exit 0" to /initramfs_files/initramfsrun.sh before the backup_mtd_partitions line and flash back original uboot and enter the initramfs again to manually recover all partitions using zcat and flashcp command except the etc and data partition (if there is data partition.) Because these two partitions use yaffs, you can just erase them using flash_eraseall.


# Need help?

Discord is your best bet if you run into any trouble! Our Discord channel: https://discord.gg/s6yJzhS4hD

Some debug information is created on the SD during the process.

Also the installion script creates telnetd ftpd for you to debug.
