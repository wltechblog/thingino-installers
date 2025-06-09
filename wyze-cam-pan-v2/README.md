# Wyze Cam Pan V2 (WYZECP2)

# This image will upgrade your camera from factory firmware to Thingino. Don't try to use this for upgrading afterwards!

# NOTE: I do not own one of these, but users have reported sucess using this image.

# This process IS reversible

The first step of this installer will create a backup of your factory firmware, which can be used to revert back to Wyze if you need to.
The factory firmware file is named combined_backup.bin and will be in WYZE_BACKUP_xxxxx/
This backup is unique PER CAMERA, so if you don't save it somewhere yourself you won't be able to revert.

The images in the installers are updated once a week, you probably want to do a full upgrade after installing!


# Installation Steps

1. Download the zip file for the wyze v3 from this repository
2. Use a sd image burning software such as Rufus or Raspberry Pi Imager to write the image to your sd card (any card 128MB or larger)
3. Power off your camera and insert the sd card, thn power it on
4. Wait around 3-4 minutes and you should see the camera's new wireless network for provisioning it.
5. After setting up the camera in webui, make sure to do a full update to current firmware as the included files are only updated periodically. You can upate via webui in `Tools->Flash Operations` or via ssh using `sysupgrade -f`

# Notes

If you are flashing multiple cameras, you need to copy and store the factory firmware backup file (combined_backup.bin), then use
your sd image burner to burn a fresh installer each time.

# Reversal Steps

To revert back to the stock Wyze firmware:

1. Ensure you're using the `combined_backup.bin` file that was generated from this exact camera. The files are not interchangable between cameras.
2. Copy `combined_backup.bin` from the `WYZE_BACKUP_xxxxx/` folder to the root of the SD card.
3. Rename `combined_backup.bin` to `autoupdate-full.bin`. This should be the only file on your SD card. You do not need any `.sha256` file.
4. Insert the SD card into your camera and plug in the power cable.
5. After a couple minutes the Wyze firmware will be restored. You do not need to manually reboot the camera.
6. When you press the `SETUP` button on the camera you'll get the original Wyze "Ready to connect" audio prompt.

# Need help?

Discord is your best bet if you run into any trouble! Our Discord channel: https://discord.gg/s6yJzhS4hD

Some debug information is created on the SD during the process.

