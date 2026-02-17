# Cinnado D1

# This image will upgrade your camera from factory firmware to Thingino. Don't try to use this for upgrading afterwards!

# NOTE

There are now 3 versions of this camera! The original model has the T31 processor, and newer models have the T23. You can visually identify which
one you have.

The T31 version has two wifi options, which you can visually identify as well. It should say Altobeam 6031, check the bottom line and if it ends with an X you need the 6031x zip file!

Recently, Cinnado D1s have been appearing with a different image sensor as well. You can't visually identify which you have.
If you use this installer and find the cam is online and seems functional but you don't have an image,
go to https://thingino.com grab the image for the Cinnado D1 with T23 and sc2331 sensor, and use the webui'd upload/flash function to switch!


This is a popular camera mostly because of its price. It is a typical PTZ 1080p camera with a T31L or T23 processor, and 8 megabyte flash.
Installation video is here: https://youtu.be/phqR49t75Ak

The images in the installers are updated once a week, you probably want to do a full upgrade after installing!

If you have trouble, jump on our Discord channel and we'll help you out!

# This process IS NOT reversible

If you need to be able to revert to factory firmware, you will need to use a flash programmer to make a backup of your firmware before flashing Thingino!
This backup is unique PER CAMERA, so if you don't save it somewhere yourself you won't be able to revert.

# Installation Steps

1. Crack open the camera and determine if you have the T31 or T23 processor. Download the zip file that matches.
2. Use a sd image burning software such as Rufus or Raspberry Pi Imager to write the image to your sd card (any card 128MB or larger)
3. Power off your camera and insert the sd card, thn power it on
4. Wait around 3-4 minutes and you should see the camera's new wireless network for provisioning it.


