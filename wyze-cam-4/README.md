# wyze cam v4

Previously, this device was unsupported due to their use of [SecureBoot](https://youtu.be/q7vhUzJtjxQ) but as of October 2026 we have fully defeated it.


# This image will upgrade your camera from factory firmware to Thingino. Don't try to use this for upgrading afterwards!

This is a popular and current camera from Wyze, which normally retails for around $45 but can be often found closer to $37.
Camera can be found at https://link.amazon/B00Powx6Y
Installation video at (pending)

# This process IS reversible

The first step of this installer will create a backup of your factory firmware, which can be used to revert back to Wyze if you need to.
The factory firmware file is named full-backup.bin and will be in wyze-backup/
This backup is unique PER CAMERA, so if you don't save it somewhere yourself you won't be able to revert.

# Special Notes

This camera is supported on Thingino's MASTER branch, which has many new components that haven't trickled down to our default builds. Also, we don't currently
produce updated firmware builds directly for it at this time, but you can always build locally or use our image builder at https://image-builder.thingino.com/

Also, there at at least TWO variants of this camera. I have ONE of them. The difference is the image sensor, and the installer attempts to detect it. It works
perfecty on my model with the os04d10 sensor, and we expect it will work with the gc4653 but as of yet I haven't confirmed this. If your install fails,
this is probably why and I need you to send methe log from the sd card to fix it!

# Installation Steps

1. Download the zip file for the wyze v4 from this repository
2. Use a sd image burning software such as Rufus or Raspberry Pi Imager to write the image to your sd card (any card 1GB or larger)
3. Power off your camera and insert the sd card, thn power it on
4. Wait around 5 minutes and you should hear our Italian greeting, folowed by a notive that the provisioining portal is up. At that time you will 
see the camera's new wireless network for provisioning it.

# Notes

If you are flashing multiple cameras, you need to copy and store the factory firmware backup file (full-backup.bin), then use
your sd image burner to burn a fresh installer each time.

# Reversal Steps

To revert back to the stock Wyze firmware:

1. Ensure you're using the `full-backup.bin` file that was generated from this exact camera. The files are not interchangable between cameras.
2. Copy `full-backup.bin` from the `WYZE-BACKUP/` folder to the root of the SD card.
3. Rename `full-backup.bin` to `autoupdate-full.bin`. This should be the only file on your SD card. You do not need any `.sha256` file.
4. Insert the SD card into your camera and plug in the power cable.
5. After a couple minutes the Wyze firmware will be restored. You do not need to manually reboot the camera.
6. When you press the `SETUP` button on the camera you'll get the original Wyze "Ready to connect" audio prompt.

# Need help?

Discord is your best bet if you run into any trouble! Our Discord channel: https://discord.gg/s6yJzhS4hD

Some debug information is created on the SD during the process. If you run into trouble, that debug file is important!

