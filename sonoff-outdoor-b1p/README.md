# SONOFF CAm Outdoor B1P

# This image will upgrade your camera from factory firmware to Thingino. Don't try to use this for upgrading afterwards!

Follow along with my Youtube video to discover and flash this camera! https://youtu.be/_9ZYJ1Lw7DU

The images in the installers are updated once a week, you probably want to do a full upgrade after installing!

# THIS PROCESS IS REVERSIBLE

A backup of your factory firmware is taken before we install Thingino, you will need to save it if you wish to go back to factory
in the future. Each camera has a unique firmware, so if you're doing multiple cams make sure to save them all!


# Installation 
1. Flash an SD card using the [Thingino Installer for the Sonoff Cam Outdoor camera](https://github.com/wltechblog/thingino-installers/tree/main/sonoff-outdoor-b1p), and insert it into the camera.
2. Use a 'dumb' USB-C cable for power only to boot the camera. Avoid using one with handshakes as they can cause confusion during the flashing process.
3. After a few minutes, the camera will begin updating its firmware. Once complete, a new WiFi network should appear called 'THING-xxx'; connect to this to access the web interface for configuration.  Refer to the [Wi-Fi Configuration Guide](https://github.com/themactep/thingino-firmware/wiki/Configuration:-Wi%E2%80%90Fi-Access#captive-portal) for further directions.
4. On checking the SD card files, there should be a new file now called 'autoupdate-full.done', which indicates the firmware process has completed.
5. This process is reversible.  To revert back to the factory firmware, you will find a folder named 'backup' on the SD card.  Save this folder separately for each camera you work with, as each camera has its unique firmware version.

# Unbricking
Unfortunately Sonoff has disabled the easier methods of unbricking, if something goes wrong and you need to recover a dead device, you'll neeed
to use a flash programmer. See the wiki at the thingino repository for info on the ch341a!
