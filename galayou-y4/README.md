# GALAYOU Y4

This is for images that don't have corresponding Wansview W7 models.
GALAYOU & Wansview models are made by the same company, some firmwares may work for both but always look for your specific model first.
I do not own any of these cams, this image is as of yet untested.
If you try it, please let me know your result!

## Determining your hardware
It is important to first know which processor (T31/T23) & WiFi chipset (ATBM6062/ATBM6062CU) you have.
Do it by following this video: https://www.youtube.com/shorts/8dlMDv3GmZ0

## SD card install instructions:
(Follow along with this video https://www.youtube.com/watch?v=jCRiIljSWlw )
1. Format micro SD card using FAT32. exfat will not work!
2. Grab the latest Thingino firmware release from https://thingino.com for the Galayou Y4 with the processor & WiFi module that matches yours.
3. Rename the thingino firmware to `autoupdate-full.bin` and move it to the SD card
4. Cleanly remove the SD from your PC and put it in the cam
5. Power up the cam and wait a few minutes, you should see the new wifi network named THINGINO you can connect to and configure the camera.

## Troubleshooting

### After I plug it in, a blue led is ON for a while and the motors rotate but i have no WiFi network to connect
This means that your cam is booting but fails to setup the WiFi hotspot. Your cam is NOT bricked :)
You may have installed the firmware with the wrong WiFi chipset (or maybe there's a new chipset that we don't cover yet).

### After I plug it in, the motors never rotate
Your cam is bricked, but don't worry! You can follow this tutorial to unbrick it: https://www.youtube.com/watch?v=xQa9lV9r4_g
