echo "=== Starting telnet with no password ==="
busybox telnetd -l /bin/sh &

echo "<br>"

for i in $(seq 1 9999); do
    sleep 100
    echo "===Runtime: $i\0 seconds===" |tr '\' '0'
    echo "<br>"
done &

echo "=== Starting jooan.sh script from sdcard ==="
echo "<br>"
/bin/sh /mnt/sd_card/jooan.sh |awk '{print $0 "<br>"; fflush()}'
#/bin/sh /tmp/upgrade/mnt/jooan.sh



sleep 10
echo "<br>"
echo "=== The jooan.sh script has exited, rebooting. ==="
