#!/bin/sh


#no flash, only backup :1
#enableflash :0
backup_only=1

audio_enable=1



#read config from thingino firmware name
thingino_firmware=$(ls /mnt/initramfs_files/thingino-* |grep -v sha256sum )
soc_model=$(echo $thingino_firmware |busybox tr '_' '\n' |busybox tail -n 3 |busybox head -n 1 )
sensor=$(echo $thingino_firmware |busybox tr '_' '\n' |busybox tail -n 2 |busybox head -n 1 )
wifi_module=$(echo $thingino_firmware |busybox tr '_' '\n' |busybox tail -n 1 |busybox tr '+' '\n' |busybox tail -n 1 |cut -d\. -f1 )
vendor=$(echo $thingino_firmware |busybox tr '_' '\n' |busybox tail -n 5 |busybox head -n 1 |busybox tr '-' '\n' | busybox tail -n 1)
device=$(echo $thingino_firmware |busybox tr '_' '\n' |busybox tail -n 4 |busybox head -n 1)
#k7ts
flash_id=$(dmesg |grep "Found Supported nand device" |busybox tr ',' '\n' |grep = |busybox tr -d ' ' |grep id |busybox cut -d \= -f2)
flash_name=$(dmesg |grep "Found Supported nand device" |busybox tr ',' '\n' |grep = |busybox tr -d ' ' |grep name |busybox cut -d \= -f2)
firmware_size=134217728
flash_size=$(total=0; for f in /sys/class/mtd/mtd*/size; do total=$((total + $(cat $f))); done; echo "$total")
#CONFIG_DEVICE_SOC=$(cat original/usr/etc/motu/$soc_model* |grep CONFIG_DEVICE_SOC= |busybox tr '=' '\n' |busybox tail -n 1 |busybox tr '"' '\0' |busybox tr '[:upper:]' '[:lower:]')
#CONFIG_DEVICE_NAME=$(cat original/usr/etc/motu/$soc_model* |grep CONFIG_DEVICE_NAME= |busybox tr '=' '\n' |busybox tail -n 1 |busybox tr '"' '\0' |busybox tr '[:upper:]' '[:lower:]')
#CONFIG_DEVICE_SENSOR=$(cat original/usr/etc/motu/$soc_model* |grep CONFIG_DEVICE_SENSOR= |busybox tr '=' '\n' |busybox tail -n 1 |busybox tr '"' '\0' |busybox tr '[:upper:]' '[:lower:]')
#IQ_FILE=$(ls /original/usr/lib/modules/* |grep -v ".ko" |grep "$sensor" |grep "t41" )




flash_check=0
for flash in "W25N01KV" ; do
    if [ "$flash_name" == "$flash" ];then
        echo flash $flash_name is supported in uboot
        flash_check=1
    fi
done
if [ $flash_check -eq 0 ];then
    echo "Flash $flash_name might not be supported in uboot"
fi




set -x
exec 1> /tmp/initramfs.log 2>&1




#k7ts audio
chroot /squash/ sh -c "modprobe $(cat /squash/etc/modules.d/40-audio)"
mkdir -p /dev/shm
mount -t tmpfs -o mode=1777,size=16M tmpfs /dev/shm
chroot /squash/ sh -c rad

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
    chroot /squash sh -c "play $audio_path 50"
    rm /var/audioplay.lock
}

tell() {
    local words="$1"
    [ -z "$words" ] && return 1

    local file_path=/var/$(mktemp -u XXXXXX).wav

    chroot /squash sh -c "espeak -w $file_path -s 150 -p 50 -ven+klatt3 \"$words\" "

    audioplay $file_path
    echo  $file_path
    rm $file_path
}


#greet
tell "Initramfs is booting... S.D. Card has been successfully detected. " & 
if [ $flash_check -eq 0 ];then
    tell "Flash $flash_name might not be supported in uboot"
fi 


##waitboot
sleep 10

## Start LED script and get its process ID
/mnt/initramfs_files/led.sh &
led_pid="$!"


CONFIG_DEVICE_SOC=$(cat original/usr/etc/motu/$soc_model* |grep CONFIG_DEVICE_SOC= |busybox tr '=' '\n' |busybox tail -n 1 |busybox tr '"' '\0' |busybox tr '[:upper:]' '[:lower:]')
CONFIG_DEVICE_NAME=$(cat original/usr/etc/motu/$soc_model* |grep CONFIG_DEVICE_NAME= |busybox tr '=' '\n' |busybox tail -n 1 |busybox tr '"' '\0' |busybox tr '[:upper:]' '[:lower:]')
CONFIG_DEVICE_SENSOR=$(cat original/usr/etc/motu/$soc_model* |grep CONFIG_DEVICE_SENSOR= |busybox tr '=' '\n' |busybox tail -n 1 |busybox tr '"' '\0' |busybox tr '[:upper:]' '[:lower:]')
IQ_FILE=$(ls /original/usr/lib/modules/* |grep -v ".ko" |grep "$sensor" |grep "t41" )



#k7ts sinfo
#if [ "X$CONFIG_DEVICE_SOC" = "Xt41nq" ] && [ "X$CONFIG_DEVICE_NAME" = "Xk7ts" ] && [ "X$CONFIG_DEVICE_SENSOR" = "Xgc4023" ] ; then
#        insmod /lib/sinfo_t41.ko i2c_adapter_nr=0 reset_gpio=18 pwdn_gpio=19 cim1_gpio=15 cim_gpio=15
#        sleep 1
#        echo 1 > /proc/jz/sinfo/info &
#fi



dd if=/original/mix/media/audio/saida_welcome.wav of=/var/welcome.wav bs=1024 count=80
audioplay /var/welcome.wav
rm /var/welcome.wav


##Report lan address.
has_wired_uplink() {
    local iface="$1"
    [ -z "$iface" ] && return 1
    ip link show "$iface" >/dev/null 2>&1 || return 1
    ip -4 route show dev "$iface" | grep -q . && return 0
    return 1
}

attempt=0
while [ "$attempt" -lt 60 ]; do
    if has_wired_uplink eth0; then
        echo "eth0 found and is up. " >&2
        export eth0_ipaddr=$(ip -4 route show dev eth0 |grep src |cut -d\  -f8)
        tell "...Wired Ethernet is connected... The I.P. address is $eth0_ipaddr ... "
        break
    fi
    attempt=$((attempt + 1))
    sleep 1
done &




dmesg > /tmp/dmesg


#eth only fix
if [ "$wifi_module" = "eth" ]; then 
    echo "eth"  >> /tmp/WIFI_MODULE
fi








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
  elif [ -e /original_etc/app/config/NetWork ]; then
    MAC=$(cat /original_etc/app/config/NetWork |busybox sed -rn 's/.*eth0..(([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}).*/\1/p' |busybox tr ':' '_')
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
backup_mtd_partitions_gz() {
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
    > "$combined_file.sh"

    # Read and process each line in /proc/mtd
    while read -r line; do
        case "$line" in
            mtd[0-9]*)
                mtd_number=$(echo "$line" | cut -d: -f1)
                mtd_name=$(echo "$line" | cut -d\" -f2)
                output_file="$backup_dir/${mtd_number}.bin"

                echo "Backing up $mtd_number ($mtd_name) to $output_file..."

                # Dump partition to a file
                if ! dd if="/dev/$mtd_number" bs=4096 conv=fsync 2>/dev/null | gzip -1 > "$output_file.gz"; then
                    echo "Error: Failed to backup $mtd_number." > "$status_file"
                    cp "$log_file" "$log_backup" 2>/dev/null
                fi

                # Generate SHA256 checksum for the dumped file
                dumped_sha=$(zcat "$output_file.gz" | sha256sum | awk '{print $1}')
		dumped_sha_gz=$(sha256sum "$output_file.gz" | awk '{print $1}')
                echo "$dumped_sha  $output_file" > "$output_file.sha256"
		echo "$dumped_sha_gz  $output_file.gz" > "$output_file.gz.sha256"

                # Generate SHA256 checksum for the live MTD partition
                mtd_sha=$(dd if="/dev/$mtd_number" bs=4096 conv=fsync 2>/dev/null | sha256sum | awk '{print $1}')

                # Compare checksums
                if [ "$dumped_sha" != "$mtd_sha" ]; then
                    echo "Error: Checksum mismatch for $mtd_number. Backup may be corrupted." > "$status_file"
                    cp "$log_file" "$log_backup" 2>/dev/null
                fi

                # Append the current partition dump to the combined file
                echo "cat \"$output_file.gz\" >> \"$combined_file.gz\"" >> "$combined_file.gz.sh"
		echo "zcat \"$output_file.gz\" >> \"$combined_file\"" >> "$combined_file.sh"

                echo "Backup and checksum validation completed for $mtd_number."
                ;;
        esac
    done < "$mtd_file"

    echo "if you want All partitions concatenated into $combined_file, run cd $backup_dir && $combined_file.sh"

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
    if [ ! -z $IQ_FILE ];then
        echo "backing up sensor iq file. "
	tell  "backing up sensor i.q. file... "
        mkdir $backup_dir/sensor
	cp $IQ_FILE $backup_dir/sensor
    fi
}

backup_yaffs_etc_data() {
    ln -s /bin/busybox /bin/bzip2
    tar -cjvf $backup_dir/original_etc.tar.bz2 /original_etc
    tar -cjvf $backup_dir/original_data.tar.bz2 /original_data
}




tell "Start backing up oringinal firmware... It could take servral minutes..."
backup_mtd_partitions_gz || exit 1
#dmesg | grep Success > /tmp/SENSOR_VER
#sensor_name=$(cat /tmp/SENSOR_VER | sed -n 's/.*Successful sensor detection: \([^,]*\),.*/\1/p')
#if [ -z "$sensor_name" ] ;then
#    sensor_name="not_found"
#fi

backup_iqfile 

backup_yaffs_etc_data

cp /tmp/initramfs.log "$backup_dir"
sync


thingino_import_iqfile() {
    SENSOR_IQ_FILE=$(ls $backup_dir/sensor |grep $sensor)
    back=$(echo $backup_dir |busybox tr '/' '\n' |busybox tail -n 1)
    if [ -z $SENSOR_IQ_FILE ];then
        tell "Can't find sensor i.q. file... something wrong."
        echo "Can't find sensor iq file. something wrong."
        return 1
    else
        rm /mnt/runonce.sh
        echo "sleep 30 &&/mnt/mmcblk0p1/importiqfile.sh & " >> /mnt/runonce.sh
        echo "mkdir -p /etc/sensor /opt/sensor " >> /mnt/importiqfile.sh
        echo "cp /mnt/mmcblk0p1/$back/sensor/$SENSOR_IQ_FILE /opt/sensor/uploaded.bin " >> /mnt/importiqfile.sh
        echo "ln -sf /opt/sensor/uploaded.bin /etc/sensor/$SENSOR_IQ_FILE " >> /mnt/importiqfile.sh
        echo "sync" >> /mnt/importiqfile.sh
        rm $SD_DIR/runonce.done
        sync
    fi
}


#check uplink
nameserver=$(cat /tmp/resolv.conf |grep nameserver |busybox tr ' ' '\n' |grep -v nameserver)
if ping -c 1 $nameserver ;then
	tell "Ethernet connection is up"
else
	tell "Ethernet connection is down, something went wrong. "
	exit 1
fi

if [ $backup_only -eq 1 ]; then
    tell "Flashing disabled."
    echo "Flashing disabled."
    exit 0
else
    tell "Flashing enabled."
    echo "Flashing enabled."
fi

if [ $flash_check -eq 1 ] && [ "X$CONFIG_DEVICE_SENSOR" = "X$sensor" ] && [ "$soc_model" =  "$(/sbin/soc -m |busybox tr -d 'z' )" ] && [ "$firmware_size" = "$flash_size" ] && [ "X$CONFIG_DEVICE_NAME" = "X$device" ] ;then
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

kill $led_pid

sleep 10

reboot -f

