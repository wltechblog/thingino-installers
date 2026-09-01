# AOQEE C1

# This process is NOT REVERSIBLE.

This installer is not able to make a backup of your factory firmware, which is required if you ever want to revert. If you want that option,
you will need to use a flash programmer to retrieve your image first.

# There are currently THREE known version of this cam!

The installer image here is for the newest version, but can be installed on any device. If your hardware differs, it's easy to switch!

If your cam powers up and announces the portal, but no wifi is visible on your phone, try switching to the aoqee_c1_t23n_sc2336_atbm6062 profile.

If you have wifi and provision the camera, but you don't have an image in the preview page, try switching to aoqee_c1_t23n_sc2336_atbm6062cu profile.

Switching is easy! Go to https://unbricker.wltechblog.com/ and select your profile, burn the created image to your sd card, and boot with the card inserted. 
You can ignore the docs about unbricking.

# Using this installer
Follow along in this video!
https://www.youtube.com/watch?v=XdIcLOpiWUk

Use Raspberry Pi Imager to burn the zip file, you do not need to unzip first. put the card in the cam and power up. Wait about 5 minutes and look for a THING wifi network.
if you don't see one, it didn't reboot on its own and you need to unplug and plug it back in. You should see the THINGINO wifi network within about 3 minutes and then
follow the normal Thingino setup!

If you hear the announcement that the config portal is up, but don't see the THING network, switching is easy! Go to thingino.com and grab the other version of the firmware for the device, remove the files on your sd card and copy it there as autoupdate-full.bin. Boot with the card inserted and it will automatically flash, whih takes about a minute.
