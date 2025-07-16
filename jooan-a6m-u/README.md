# JOOAN A6M-U

# This image will upgrade your camera from factory firmware to Thingino. Don't try to use this for upgrading afterwards!

Follow along with my Youtube video to discover and flash this camera! COMING SOON

The images in the installers are updated once a week, you probably want to do a full upgrade after installing!

# THIS PROCESS IS NOT REVERSIBLE

Using the ONE TOOL install method, it's a one-way street. You can always flash Thingino and other third party firmwares, but if you want the
option of reverting to the factory firmware you will need to take a backup using a flash programmer.

# Instructions

Follow along in the youtube video, but these are the steps:
1. Take the camera apart
2. Identify your WIFI chip, either Altobeam 6012bx or SSV6355
3. Download the matching jooan zip from this repo
4. Use your favorite SD image burner to write it to SD
5. Insert your SD card
6. Create a short on the spi flash chip pins 5 and 6
7. Power up the cam. Wait 1.5 seconds and remove the short.
8. Wait a minute and the camera will boot to Thingino.
