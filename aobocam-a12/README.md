# Aobocam A12

## This image will upgrade your camera from factory firmware to Thingino. It won't work for upgrading afterwards.

Camera model: https://amzn.com/dp/B0DHL7MKBN

If you have trouble, jump on our Discord channel and we'll help you out!

The images in the installers are updated once a week, you probably want to do a full upgrade after installing!


## This process SHOULD BE Reversible (not tested)

The first step of this installer will create a backup of your factory firmware, which can be used to revert back to the original firmware if you need to.
The factory firmware file is named factory.bin and will be in backup/
This backup is unique PER CAMERA, so if you don't save it somewhere yourself you won't be able to revert.

## Installation Steps

1. Download the zip file for the Aobocam a12 from this repository
2. Use a sd image burning software such as Rufus, Etcher, or Raspberry Pi Imager to write the image to your sd card (any card 128MB or larger)
3. Power off your camera and insert the sd card, thn power it on
4. Wait around 3-4 minutes and you should see the camera's new wireless network for provisioning it.

### Notes

If you are flashing multiple cameras, you need to copy and store the factory firmware backup file (factory.bin), then use
your sd image burner to burn a fresh installer each time.
