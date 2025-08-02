# SONOFF CAM SLIM Gen2

# This image will upgrade your camera from factory firmware to Thingino. Don't try to use this for upgrading afterwards!

Follow along with my Youtube video to discover and flash this camera! COMING SOON

The images in the installers are updated once a week, you probably want to do a full upgrade after installing!

# THIS PROCESS IS REVERSIBLE

A backup of your factory firmware is taken before we install Thingino, you will need to save it if you wish to go back to factory
in the future. Each camera has a unique firmware, so if you're doing multiple cams make sure to save them all!


# Installation 
1. Flash an SD card using the [Thingino Installer for the Sonoff Slim Gen 2 camera](https://github.com/wltechblog/thingino-installers/tree/main/sonoff-slim-gen-2), and insert it into the camera.
2. Use a 'dumb' USB-C cable for power only to boot the camera. Avoid using one with handshakes as they can cause confusion during the flashing process.
3. After a few minutes, the camera will begin updating its firmware. Once complete, a new WiFi network should appear called 'THING-xxx'; connect to this to access the web interface for configuration.  Refer to the [Wi-Fi Configuration Guide](https://github.com/themactep/thingino-firmware/wiki/Configuration:-Wi%E2%80%90Fi-Access#captive-portal) for further directions.
4. On checking the SD card files, there should be a new file now called 'autoupdate-full.done', which indicates the firmware process has completed.
5. This process is reversible.  To revert back to the factory firmware, you will find a folder named 'backup' on the SD card.  Save this folder separately for each camera you work with, as each camera has its unique firmware version.

If any complications arise during the flashing process such as an incomplete update of the firmware, some light surgery may be required:
1. Turn off the power supply to the camera.
2. Disassemble the camera from its housing by carefully separating it around the corners (held in by pressure, not glue).
3. Unscrew the PCB from the housing, and gently lift out.  Unplug the black and red cable from the speaker (marked SPK on the PCB).
4. Turn over the PCB, to find the flash chip as circled in [this image](https://github.com/wltechblog/thingino-installers/blob/6f7a453b869ec47d360379fff3f112bb8258004c/sonoff-slim-gen-2/PCB%20-%20Flash%20Chip.jpeg).
5. Locate and identify [pins 5 and 6 on the flash chip #TODO]() using the circle as the pin #1 reference point, then count counter-clockwise.
6. Bridge pins 5 and 6 by holding a metal screwdriver or needle across the pins, while connecting the power cable to the camera.  Remove the screwdriver/needle about a second later.  Refer to the creator's [YouTube Video walkthrough](https://www.youtube.com/watch?v=wfeA8wOEe34&t=480s) for visual guidance (the camera is a different model, but the process is the same).  It may take a few tries to get the timing right.
7. The camera should boot from the SD card and complete the firmware flashing process. Monitor for the `THING-xxx` WiFi network to appear.
8. Once completed, reassemble the camera by remembering to connect the speaker cable, screwing the PCB back into the housing, etc.
