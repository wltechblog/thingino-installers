# JOOAN W3-U

# This image will upgrade your camera from factory firmware to Thingino. Don't try to use this for upgrading afterwards!

More info on this cam coming soon! Follow the same process as the A2R-U! https://youtu.be/wfeA8wOEe34

The images in the installers are updated once a week, you probably want to do a full upgrade after installing!

# THIS PROCESS IS NOT REVERSIBLE

Using the ONE TOOL install method, it's a one-way street. You can always flash Thingino and other third party firmwares, but if you want the
option of reverting to the factory firmware you will need to take a backup using a flash programmer.

# Instructions

Follow along in the youtube video, but these are the steps:
1. Take the camera apart
2. Download the matching jooan zip from this repo
3. Use your favorite SD image burner to write it to SD
4. Insert your SD card
5. Create a short on the spi flash chip pins 5 and 6
6. Power up the cam. Wait 1.5 seconds and remove the short.
7. Wait a minute and the camera will boot to Thingino.
