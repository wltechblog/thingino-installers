# Wyze Cam V3 (WYZEC3)

This is a popular and current camera from Wyze, which normally retails for around $30 but can be often found closer to $20.
Camera can be found at https://amzn.to/3zK7DoS
Installation video at https://youtu.be/SX637mrp0R0

# This process IS reversible

The first step of this installer will create a backup of your factory firmware, which can be used to revert back to Wyze if you need to.
The factory firmware file is named combined_backup.bin and will be in WYZE_BACKUP_xxxxx/
This backup is unique PER CAMERA, so if you don't save it somewhere yourself you won't be able to revert.

# Installation Steps

1. Format your SD card to fat32 (not exfat!)
2. Unzip the contents of wyzev3-flasher.zip to the root of the sd card
3. Insert the sd card into the camera and boot it up.
4. Wait around 3-4 minutes and you should see the camera's new wireless network for provisioning it.

# Notes

If you are flashing multiple cameras, you need to format and recreate the sd card each time. If you want the ability to revert, you need to copy the combined_backup.bin file from each device and note
which one goes to which camera.

# Need help?

Discord is your best bet if you run into any trouble! Our Discord channel: https://discord.gg/s6yJzhS4hD

Some debug information is created on the SD during the process.

