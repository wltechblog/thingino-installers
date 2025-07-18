# WUUK Y0510

# This image will upgrade your camera from factory firmware to Thingino. Don't try to use this for upgrading afterwards!

This is my favorite cam so far! After playing with a bunch of lower end devices it's refreshing to have a premium one.
Buy your own! https://amzn.to/4fJRcc5
Installation video at https://youtu.be/4-NrAt4KjkE

If you have trouble, jump on our Discord channel and we'll help you out!

The images in the installers are updated once a week, you probably want to do a full upgrade after installing!


# This process IS Reversible

The first step of this installer will create a backup of your factory firmware, which can be used to revert back to WUUK if you need to.
The factory firmware file is named factoryp.bin and will be in backup/
This backup is unique PER CAMERA, so if you don't save it somewhere yourself you won't be able to revert.

# Installation Steps

1. Download the zip file for the wuuk y0510 from this repository
2. Use a sd image burning software such as Rufus or Raspberry Pi Imager to write the image to your sd card (any card 128MB or larger)
3. Power off your camera and insert the sd card, thn power it on
4. Wait around 3-4 minutes and you should see the camera's new wireless network for provisioning it.

# Notes

If you are flashing multiple cameras, you need to copy and store the factory firmware backup file (factory.bin), then use
your sd image burner to burn a fresh installer each time.

# Reversal Steps

To revert back to the stock WUUK firmware:

1. Ensure you're using the `factory.bin` file that was generated from this exact camera. The files are not interchangable between came>
2. Copy `factory.bin` from the `backup/` folder to the root of the SD card.
3. Rename `factory.bin` to `autoupdate-full.bin`. This should be the only file on your SD card. You do not need any `.sha256` file.
4. Insert the SD card into your camera and plug in the power cable.
5. After a couple minutes the WUUK firmware will be restored. You do not need to manually reboot the camera.
