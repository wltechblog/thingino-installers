# AOQEE C1

# This process is NOT REVERSIBLE.

This installer is not able to make a backup of your factory firmware, which is required if you ever want to revert. If you want that option,
you will need to use a flash programmer to retrieve your image first.

# There are currently TWO known version of this cam!

They changed the WIFI chip at some point with a new version, and it's not obvious from the outside which one you have. You can easily disassemble the camera to find out, or it's
actually safe and easy to try one image and switch to the other if it doesn't come up on wifi.

If you bought your cam after September 2025, I suggest you try the 6062CU image first.

if you chose the wrong one and need to switch, the easiest method to do so is to burn the other image and rename the file v4_all.bin to autoupdate-full.bin, then boot the cam with the card inserted!

# Using this installer
Follow along in this video!
https://www.youtube.com/watch?v=XdIcLOpiWUk

Use Raspberry Pi Imager to burn the zip file, you do not need to unzip first. put the card in the cam and power up. Wait about 5 minutes and look for a THING wifi network.
if you don't see one, it didn't reboot on its own and you need to unplug and plug it back in. You should see the THINGINO wifi network within about 3 minutes and then
follow the normal Thingino setup!

If you hear the announcement that the config portal is up, but don't see the THING network, switching is easy! Go to thingino.com and grab the other version of the firmware for the device, remove the files on your sd card and copy it there as autoupdate-full.bin. Boot with the card inserted and it will automatically flash, whih takes about a minute.
