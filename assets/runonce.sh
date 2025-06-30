#!/bin/sh
/bin/echo yes | /sbin/thingino-diag -l /tmp
mv /tmp/thingino-diag* /mnt/mmcblk0p1/
sync
umount /mnt/mmcblk0p1
/bin/iac  -f /usr/share/sounds/thingino.pcm
