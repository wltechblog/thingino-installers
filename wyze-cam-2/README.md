# Wyze Cam V2 (WYZEC2) and NEOS SmartCam

This was a popular model for a long tiem and while I don't recommend buying a new one today, lots of folks already have them and they are plentiful in the used market.
Installation video at https://www.youtube.com/watch?v=Ax6usUOjxkY

If you have trouble, jump on our Discord channel and we'll help you out!

# Installation Steps

1. Format your SD card to fat32 (not exfat!)
2. Unzip the contents of wyze-cam-2.zip to the root of the sd card
3. Cleanly unmount the sd card and put into the sd slot on the bottom of the camera
4. Hold down the reset button while plugging in, continue to hold until the status light turns blue, about 5 seconds.
5. If everything is correct, the process takes just under 4 minutes.
6. You should now see the camera's new wireless network for provisioning it.
7. After setting up the camera in webui, make sure to update to current firmware as the included files are only updated periodically. You can upate via webui in `Tools->Sysupgrade tool` or via ssh using `sysupgrade -p`

# Reversal Steps

To revert back to the stock Wyze firmware:

1. Ensure you're using the `combined_backup.bin` file that was generated from this exact camera. The files are not interchangable between cameras.
2. Copy `combined_backup.bin` from the `WYZE_BACKUP_xxxxx/` folder to the root of the SD card.
3. Rename `combined_backup.bin` to `autoupdate-full.bin`. This should be the only file on your SD card. You do not need any `.sha256` file.
4. Insert the SD card into your camera and plug in the power cable.
5. After a couple minutes the Wyze firmware will be restored. You do not need to manually reboot the camera.
6. When you press the `SETUP` button on the camera you'll get the original Wyze "Ready to connect" audio prompt.