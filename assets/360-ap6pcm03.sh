#!/bin/sh

audio_enable=1

#no flash, only backup :1
#enableflash :0
backup_only=0




#read config from thingino firmware name
thingino_firmware=$(ls /mnt/initramfs_files/thingino-* |grep -v sha256sum )
soc_model=$(echo $thingino_firmware |busybox tr '_' '\n' |busybox tail -n 3 |busybox head -n 1 )
sensor=$(echo $thingino_firmware |busybox tr '_' '\n' |busybox tail -n 2 |busybox head -n 1 )
wifi_module=$(echo $thingino_firmware |busybox tr '_' '\n' |busybox tail -n 1 |busybox tr '+' '\n' |busybox tail -n 1 |cut -d\. -f1 )
##ap6pcm03
firmware_size=33554432
flash_size=$(total=0; for f in /sys/class/mtd/mtd*/size; do total=$((total + $(cat $f))); done; echo "$total")
flash_id=$(dmesg  |grep "the id code" |grep "the flash name" |busybox tr ',' '\n' |grep = |busybox tr -d ' ' |busybox cut -d \= -f2)
flash_name=$(dmesg  |grep "the id code" |grep "the flash name" |busybox tr ',' '\n' |grep -v = |busybox tr ' ' '\n' |grep  '[[:upper:]]')
flash_check=0
#EN25QH256A is now supported in mainline uboot
for flash in "XM25QH256C" "EN25QH256A" ; do
    if [ "$flash_name" == "$flash" ];then
        echo flash $flash_name is supported in uboot
        flash_check=1
    fi
done
if [ $flash_check -eq 0 ];then
    echo "Flash $flash_name might not be supported in uboot"
fi


#nvram_get MAC
#nvram_get MAC1
#nvram_get WIFI
#nvram_get UID
#nvram_get X_STEPS
#nvram_get Y_STEPS
#nvram_get CC_CUEI_360
#nvram_get PROJ

##ap6pcm03_wifi
#gpio-diag PB21 gpio_output
#gpio-diag PB21  write 1
##ap6pcm03_eth
#gpio-diag PB20 gpio_output
#gpio-diag PB20  write 1





set -x
exec 1> /tmp/initramfs.log 2>&1

## Start LED script and get its process ID
/mnt/initramfs_files/led.sh &
led_pid="$!"


##waitboot
sleep 10



#audio
busybox chroot /squash/ sh -c 'modprobe audio' &

#wired
#PCM03
#gpio-diag PB20 write 1
busybox chroot /squash/ sh -c 'service network start' &


##wireless
busybox chroot /squash/ sh -c 'service wireless start'
busybox chroot /squash/ sh -c 'wpa_supplicant  -i wlan0 -c /mnt/initramfs_files/wpa_initramfs.conf -B'
ifconfig wlan0 172.16.0.1 netmask 255.255.255.0 &
udhcpd /mnt/initramfs_files/udhcpd-initramfs.conf &






##startup music
#export audio_file=a_on.wav
#chroot /squash sh -c 'LD_LIBRARY_PATH=/mnt/initramfs_files/ /mnt/initramfs_files/audioplay_t31 /mnt/initramfs_files/$audio_file 50'

audioplay() {
    local audio_path="$1"
    [ -z "$audio_path" ] && return 1

    if [ "$audio_enable" -eq 0 ]; then
        return
    fi

    while [ -f "/var/audioplay.lock" ]; do
       echo "Some audio is playing."
       sleep 2
    done

    echo $audio_path > /var/audioplay.lock
    chroot /squash sh -c "LD_LIBRARY_PATH=/mnt/initramfs_files/ /mnt/initramfs_files/audioplay_t31 $audio_path 50"
    rm /var/audioplay.lock
}


tell() {
    local words="$1"
    [ -z "$words" ] && return 1

    local file_path=/var/$(mktemp -u XXXXXX).wav

    chroot /squash sh -c "LD_LIBRARY_PATH=/mnt/initramfs_files/ /mnt/initramfs_files/espeak --path=/mnt/initramfs_files -w $file_path -s 150 -p 50 -ven+klatt3 \"$words\" "

    audioplay $file_path 
    echo  $file_path
    rm $file_path
}

tell "Initramfs is booting... S.D. Card has been successfully detected. " 
if [ $flash_check -eq 0 ];then
    tell "Flash $flash_name might not be supported in uboot"
fi


##Report lan address.
has_wired_uplink() {
    local iface="$1"
    [ -z "$iface" ] && return 1
    ip link show "$iface" >/dev/null 2>&1 || return 1
    ip -4 route show dev "$iface" | grep -q . && return 0
    return 1
}

attempt=0
while [ "$attempt" -lt 15 ]; do
    if has_wired_uplink eth0; then
        echo "eth0 found and is up. " >&2
        export eth0_ipaddr=$(ip -4 route show dev eth0 |grep src |cut -d\  -f8)
        tell "...Wired Ethernet is connected... The I.P. address is $eth0_ipaddr ... "
        break
    fi
    attempt=$((attempt + 1))
    sleep 1
done 


#wifi hotspot

if [ -e /sys/class/net/wlan0/operstate ] ;then
    wlan0_state=$(cat /sys/class/net/wlan0/operstate)

    if_wpa=$(ps | grep wpa_sup )
    if_wpa=$(echo $if_wpa | grep wpa_supplicant )
    if [ -z "$if_wpa" ] && [ !"$wlan0_state" = "up" ] && [ !has_wired_uplink wlan0 ]; then
        echo "Wifi is not up. Something might be wrong"
    else
        export wlan0_ipaddr=$(ip -4 route show dev wlan0 |grep src |cut -d\  -f8)
        echo "Wifi is up."
        tell "...Wifi is up... The I.P. address is $wlan0_ipaddr ... "
    fi
fi


##usb cdc
cdc_ipaddr=$(ip -4 route show dev usb0 |grep src |cut -d\  -f8)
if [ -z $cdc_ipaddr ]; then
    echo "USB cdc network is not loaded. "
    tell "USB cdc network is not loaded. "
else
    echo "USB cdc network is configured, The IP address is $cdc_ipaddr  "
    tell "...USB cdc network is configured... The I.P. address is $cdc_ipaddr ... "

fi


if_network () {
    if [ -z "$wlan0_ipaddr" ] && [ -z "$eth0_ipaddr" ] && ! grep -q "up" "/sys/class/net/usb0/operstate" ;then
        echo "Both wired and wireless ethernet is not up, something might be wrong"
        tell "Both wired and wireless ethernet is not up... something might be wrong... "
        return 1
    else
        echo "Network is up. "
        return 0
    fi
}


if ! if_network ;then 
    echo "network not up."
    exit 1
fi








# Main script execution starts here
echo "Welcome to initramfs for Thingino"




# Function to generate a backup directory
generate_backup_dir() {
  base_dir="/mnt"

  if [ -e /bin/nvram_get ]; then
    MAC=$(nvram_get MAC |grep : |busybox tr ':' '_')
    backup_dir="$base_dir/360_BACKUP_$MAC"
    if [ -z "$MAC" ];then 
      echo "Get mac address error. " > /dev/null
      tell "Get mac address error. " > /dev/null
      template="$base_dir/ORIG_BACKUP_XXXXXX"

      # Create a unique temporary directory
      backup_dir=$(mktemp -d -p "$base_dir" "ORIG_BACKUP_XXXXXX" 2>/dev/null)
      if [ -z "$backup_dir" ]; then
        echo "Error: Unable to create a unique directory in $base_dir." > /dev/null
        tell "Error: Unable to create a unique directory in $base_dir." > /dev/null
        return 1
      fi
    fi
  else
    template="$base_dir/ORIG_BACKUP_XXXXXX"

    # Create a unique temporary directory
    backup_dir=$(mktemp -d -p "$base_dir" "ORIG_BACKUP_XXXXXX" 2>/dev/null)
    if [ -z "$backup_dir" ]; then
      echo "Error: Unable to create a unique directory in $base_dir." > /dev/null
      tell "Error: Unable to create a unique directory in $base_dir." > /dev/null
      return 1
    fi
  fi
  mkdir -p "$backup_dir"
  export backup_dir=$backup_dir
  echo "$backup_dir"
}

# Function to backup MTD partitions
backup_mtd_partitions() {
    mtd_file="/proc/mtd"
    log_file="/tmp/initramfs.log"
    backup_dir=$(generate_backup_dir)
    status_file="$backup_dir/STATUS"
    log_backup="$backup_dir/initramfs.log"
    combined_file="$backup_dir/combined_backup.bin"

    [ -z "$backup_dir" ] && return 1
    # Check if /proc/mtd exists
    if [ ! -f "$mtd_file" ]; then
        echo "Error: $mtd_file not found. Are you running on a system with MTD partitions?" > "$status_file"
        tell "Error: $mtd_file not found. Are you running on a system with MTD partitions?"
        cp "$log_file" "$log_backup" 2>/dev/null
        return 1
    fi

    # Create the combined file
    > "$combined_file"

    # Read and process each line in /proc/mtd
    while read -r line; do
        case "$line" in
            mtd[0-9]*)
                mtd_number=$(echo "$line" | cut -d: -f1)
                mtd_name=$(echo "$line" | cut -d\" -f2)
                output_file="$backup_dir/${mtd_number}.bin"

                echo "Backing up $mtd_number ($mtd_name) to $output_file..."

                # Dump partition to a file
                if ! dd if="/dev/$mtd_number" of="$output_file" bs=4096 conv=fsync 2>/dev/null; then
                    echo "Error: Failed to backup $mtd_number." > "$status_file"
                    cp "$log_file" "$log_backup" 2>/dev/null
                fi

                # Generate SHA256 checksum for the dumped file
                dumped_sha=$(sha256sum "$output_file" | awk '{print $1}')
                echo "$dumped_sha  $output_file" > "$output_file.sha256"

                # Generate SHA256 checksum for the live MTD partition
                mtd_sha=$(dd if="/dev/$mtd_number" bs=4096 conv=fsync 2>/dev/null | sha256sum | awk '{print $1}')

                # Compare checksums
                if [ "$dumped_sha" != "$mtd_sha" ]; then
                    echo "Error: Checksum mismatch for $mtd_number. Backup may be corrupted." > "$status_file"
                    cp "$log_file" "$log_backup" 2>/dev/null
                fi

                # Append the current partition dump to the combined file
                cat "$output_file" >> "$combined_file"

                echo "Backup and checksum validation completed for $mtd_number."
                ;;
        esac
    done < "$mtd_file"

    # Generate checksum for the combined file
    combined_sha=`sha256sum "$combined_file" | awk '{print $1}'`
    echo "$combined_sha  $combined_file" > "$combined_file.sha256"

    echo "All partitions have been concatenated into $combined_file."

    if grep -q "Error" "$status_file"; then
        status=$(cat $status_file )
        tell "$status"
	cp "$log_file" "$log_backup" 2>/dev/null
        return 1
    else
        tell "Original firmware backup success..."
        return 0
    fi
}


backup_iqfile() {
    if [ -e /original/usr/system/etc_rw/sensor/ ];then
        echo "backing up sensor iqfile. "
        cp -r /original/usr/system/etc_rw/sensor/ $backup_dir
    fi
}





##mmc wifi module
if [ -e /sys/devices/platform/jzmmc_v1.2.1/mmc_host/mmc1/mmc1:*/mmc1:*/vendor ] ;then
    echo "vendor: $(cat /sys/devices/platform/jzmmc_v1.2.1/mmc_host/mmc1/mmc1:*/mmc1:*/vendor)" >> /tmp/WIFI_MODULE
    echo "device: $(cat /sys/devices/platform/jzmmc_v1.2.1/mmc_host/mmc1/mmc1:*/mmc1:*/device)" >> /tmp/WIFI_MODULE
fi

##usb wifi module
cat /sys/kernel/debug/usb/devices |grep Vendor |cut -d $'\n' -f2 |busybox tr ' ' '\n' |grep Vendor= >> /tmp/WIFI_MODULE
##example: Vendor=0bda
cat /sys/kernel/debug/usb/devices |grep Vendor |cut -d $'\n' -f2 |busybox tr ' ' '\n' |grep ProdID= >> /tmp/WIFI_MODULE
#eth only fix


dmesg | grep Success > /tmp/SENSOR_VER
dmesg > /tmp/dmesg

#360 nvram variable
if [ -e /bin/nvram_get ]; then
    for nvram_name in MAC MAC1 WIFI UID X_STEPS Y_STEPS CC_CUEI_360 PROJ ; do
        echo "$nvram_name : $(nvram_get $nvram_name)" >> /tmp/360nvram.var
    done
fi

# Erase MTD partition and finalize backup process
#echo "Erasing..."
#flash_eraseall /dev/mtd0
#echo "mtd0 erasing completed"

#echo "Erase Flash thingino u-boot"
#if [ "$(/sbin/soc -m)" = "t31x" ]; then
  ##flashcp -v /root/u-boot-isvp_t31_sfcnor_ddr128M.bin /dev/mtd0
#  echo "Flash update currently disabled."
#else
#  echo "SoC not supported in this installer"
#fi

sensor_name=$(cat /tmp/SENSOR_VER | sed -n 's/.*Successful sensor detection: \([^,]*\),.*/\1/p')
if [ -z "$sensor_name" ] ;then
    sensor_name="not_found"
fi


##wifi module detection
if grep -q ':' /tmp/WIFI_MODULE 2>/dev/null ;then
    echo wifi is sdio
    if grep -q "vendor: 0x007a" /tmp/WIFI_MODULE 2>/dev/null ;then
        echo "Altobeam ATBM" >> /tmp/WIFI_MODULE
        if grep -q "device: 0x6011" /tmp/WIFI_MODULE 2>/dev/null ;then
	    echo "atbm6031" >> /tmp/WIFI_MODULE
        fi
    fi
        
elif grep -q '=' /tmp/WIFI_MODULE 2>/dev/null ;then
    echo wifi is usb
    if grep -q "Vendor=0bda" /tmp/WIFI_MODULE 2>/dev/null ;then
        echo "Realtek RTL" >> /tmp/WIFI_MODULE
	if grep -q "ProdID=f179" /tmp/WIFI_MODULE 2>/dev/null ;then
            echo "rtl8188ftv"  >> /tmp/WIFI_MODULE
        fi
    fi
fi


#eth only fix
if [ "$wifi_module" = "eth" ]; then 
    echo "eth"  >> /tmp/WIFI_MODULE
fi



# Perform MTD partition backup
tell "start backing up mtd partitions "&
backup_mtd_partitions  || exit 1
backup_iqfile

# Copy logs to backup directory
cp /tmp/* "$backup_dir"
sync



if [ $backup_only -eq 1 ]; then
    echo "Flashing disabled."
    tell "Flashing disabled."
    exit 0
else
    echo "Flashing enabled."
fi






thingino_import_iqfile() {
    SENSOR_IQ_FILE=$(ls $backup_dir/sensor |grep $sensor_name)
    back=$(echo $backup_dir |busybox tr '/' '\n' |busybox tail -n 1)
    if [ -z $SENSOR_IQ_FILE ];then
        tell "Can't find sensor i.q. file... something wrong."
        echo "Can't find sensor iq file. something wrong."
        return 1
    else
        rm /mnt/runonce.sh
        echo "mkdir -p /etc/sensor /opt/sensor " >> /mnt/runonce.sh
        echo "cp /mnt/mmcblk0p1/$back/sensor/$SENSOR_IQ_FILE /opt/sensor/uploaded.bin " >> /mnt/runonce.sh
        echo "ln -sf /opt/sensor/uploaded.bin /etc/sensor/$SENSOR_IQ_FILE " >> /mnt/runonce.sh
        echo "sync" >> /mnt/runonce.sh
        rm $SD_DIR/runonce.done
        sync
    fi
}




#debug
echo $sensor_name
echo $sensor
echo $wifi_module
echo $soc_model
echo $firmware_size
echo $flash_size
echo $flash_id
echo $flash_name

##ap6pcm03
if [ $flash_check -eq 1 ] && [ "$sensor_name" = "$sensor" ] && grep -q "$wifi_module" /tmp/WIFI_MODULE 2>/dev/null && [ "$soc_model" =  "$(/sbin/soc -m |busybox tr -d 'z' )" ] && [ "$firmware_size" = "$flash_size" ] && [ $(nvram_get WIFI) = "atbm603x" ] ;then
    #echo "All verifyed. Press button to start flash"
    
    tell "Sensor model and wifi module and soc model are checked... start flashing firmware... "
    tell "Count down... Cut down the power immedicatlt to cancel... 10... 9... 8... 7... 6... 5... 4... 3... 2... 1... 0... start "
    tell "... Now start flashing... do not cut the power now... It will take five minutes..."
    umount /dev/mtdblock*
    umount /dev/mtdblock*
    umount /dev/mtdblock*
    /mnt/initramfs_files/uniflasher.sh $thingino_firmware
    echo "flashing firmware"
    thingino_import_iqfile
    #cp $thingino_firmware /mnt/autoupdate-full.bin
    touch /mnt/autoupdate-full.done
    sync
    tell "The firmware is flashed, rebooting ..."
    #exit 0
else
    echo "The hardware is diffreent from what u choose ..."
    tell "The hardware is diffreent from what u choose ..."
    exit 1
fi



# Reboot and clean up
echo "Rebooting..."

cp "$log_file" "$log_backup" 2>/dev/null

# Sync file systems and unmount the SD card
sync

## Kill the LED process
kill $led_pid


sleep 10
# Reset the system using watchdog
echo wdt > /proc/jz/reset/reset

