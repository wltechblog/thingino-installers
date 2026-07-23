#!/bin/sh



#no flash, only backup
backup_only=0

#timeout to keep device on when only do backup or when something wrong.
#even if we set it, the camera might still reboot after 1421 seconds.
timeout=10000000

#enable wifi accesspoint for debug. WARNING: It could break the current link if u are accessing it through wifi.
wifi_ap=0


SD_DIR="/mnt/sd_card"




##add sha256sum and cut command
if [ ! -f "$SD_DIR/busybox_static" ]; then
    echo "busybox_static does not exist."
    sleep $timeout
fi
cut() { $SD_DIR/busybox_static cut "$@"; }
sha256sum() { $SD_DIR/busybox_static sha256sum "$@"; }

##ftpd
$SD_DIR/busybox_static tcpsvd -vE 0.0.0.0 21 $SD_DIR/busybox_static ftpd -w -A  / &

#get mac and board name
MAC=$(cat /config/.fix | tr "\0" "\n" | grep . |grep : )
if [ -z "$MAC" ]; then
    MAC=$( cat /sys/class/net/eth0/address |grep : )
fi
if [ -z "$MAC" ]; then
    echo "unable to get mac address."
    sleep $timeout
fi
MAC=$(echo $MAC |tr ':' '_' |tr -d ' ' )


Brand_Name=$(printenv |grep "^Brand_Name" |tr '=' '\n' |tail -n 1 )
if [ -z "$Brand_Name" ]; then
    Brand_Name=$( cat /mnt/mtd/product_name )
fi
if [ -z "$Brand_Name" ]; then
    echo "unable to get Brand_Name."
    sleep $timeout
fi
Brand_Name=$( echo $Brand_Name | tr -d ' ' )


##wifi

if [ ! -e  $SD_DIR/wpa_jooan.conf ];then
cat <<EOF > $SD_DIR/wpa_jooan.conf
ctrl_interface=/var/run/wpa_supplicant
ap_scan=2

network={
        ssid="JOOAN-AP"
        mode=2
        #psk="installer"
        psk=40cf9717a16e9dd659c1a8c61ef09177faeceeb74365235cf0eba2aece759e47
}
EOF
fi

if [ ! -e  $SD_DIR/udhcpd-jooan.conf ];then
cat <<EOF > $SD_DIR/udhcpd-jooan.conf
start           172.16.0.1
end             172.16.0.254
interface       wlan0
max_leases      16
remaining       no
auto_time       7200  # 2 hr
decline_time    3600  # 1 hr
conflict_time   3600  # 1 hr
offer_time      60    # 1 min
min_lease       60    # 1 min
lease_file      /var/run/udhcpd.leases
pidfile         /var/run/udhcpd.pid
#notify_file     dumpleases

opt     dns     172.16.0.1
option  subnet  255.255.255.0
opt     router  172.16.0.1
option  domain  local
option  lease   864000
EOF
fi


if [ $wifi_ap -eq 1 ] ; then
	killall -9 wpa_supplicant
	$SD_DIR/wpa_supplicant  -i wlan0 -c $SD_DIR/wpa_jooan.conf -B
	ifconfig wlan0 172.16.0.1 netmask 255.255.255.0 &
	udhcpd $SD_DIR/udhcpd-jooan.conf &
fi










# Function to generate a backup directory
generate_backup_dir() {
  base_dir=$SD_DIR
#  template="$base_dir/N3431H_BACKUP_XXXXXX"
#
#  # Create a unique temporary directory
#  backup_dir=$(mktemp -d -p "$base_dir" "N3431H_BACKUP_XXXXXX" 2>/dev/null)
#  if [ -z "$backup_dir" ]; then
#    echo "Error: Unable to create a unique directory in $base_dir."
#    sleep $timeout
#  fi
  backup_dir=$SD_DIR/$Brand_Name\_BACKUP_$MAC
  export backup_dir=$SD_DIR/$Brand_Name\_BACKUP_$MAC
  mkdir $backup_dir
  echo "$backup_dir"
}


# Function to backup MTD partitions
backup_mtd_partitions() {
    mtd_file="/proc/mtd"
    log_file="/tmp/backup.log"
    backup_dir=$(generate_backup_dir)
    status_file="$backup_dir/STATUS"
    log_backup="$backup_dir/backup.log"
    combined_file="$backup_dir/combined_backup.bin"

    # Check if /proc/mtd exists
    if [ ! -f "$mtd_file" ]; then
        echo "Error: $mtd_file not found. Are you running on a system with MTD partitions?" > "$status_file"
        cp "$log_file" "$log_backup" 2>/dev/null
        sleep $timeout
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
                    echo "Error: Failed to backup $mtd_number." >> "$status_file"
                    cp "$log_file" "$log_backup" 2>/dev/null
                fi

                # Generate SHA256 checksum for the dumped file
                dumped_sha=$(sha256sum "$output_file" | awk '{print $1}')
                echo "$dumped_sha  $output_file" > "$output_file.sha256"

                # Generate SHA256 checksum for the live MTD partition
                mtd_sha=$(dd if="/dev/$mtd_number" bs=4096 2>/dev/null | sha256sum | awk '{print $1}')

                # Compare checksums
                if [ "$dumped_sha" != "$mtd_sha" ]; then
                    echo "Error: Checksum mismatch for $mtd_number. Backup may be corrupted." >> "$status_file"
                    echo "$mtd_number $dumped_sha $mtd_sha mismatch."
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
        echo "$status"
        sleep $timeout
    else
        return 0
    fi
}

backup_iqfile() {
    if [ -e /mnt/mtd/etc/sensor/ ];then
        echo "backing up sensor iqfile. "
        cp -r /mnt/mtd/etc/sensor/ $backup_dir
    else 
        echo "Iqfile backup failed."
        sleep $timeout
    fi
}


backup_mtd_partitions

if [ $? -eq 0 ]; then
    echo "Backup success."
else
    echo "Backup failed. Please telnet to camera ip and see why. " 
    sleep $timeout
fi

backup_iqfile

mount -t debugfs none /sys/kernel/debug
cat /sys/kernel/debug/gpio >> $backup_dir/gpio.back
dmesg >> $backup_dir/dmesg.back







if [ $backup_only -eq 1 ]; then
    echo "Flashing disabled. "
    sleep $timeout
else
    echo "Flashing enabled."
fi



















##uniflahser_update_fw: Check image checksum, erase and write everything.
uniflasher_update_fw() {
    thingino_fw_name="$1"

    if [ -z "$thingino_fw_name" ]; then
        echo "Firmware name missing." 
        return 1
    fi

    if [ ! -f "$SD_DIR/$thingino_fw_name" ]; then
        echo "Firmware file $thingino_fw_name does not exist."
        return 1
    fi
    if [ ! -f "$SD_DIR/$thingino_fw_name.sha256sum" ]; then
        echo "Firmware checksum $thingino_fw_name.sha256sum does not exist." 
        return 1
    fi

    if [ ! -f "$SD_DIR/uniflasher.sh" ]; then
        echo "uniflasher.sh does not exist."
        return 1
    fi

    if [ $(sha256sum  "$SD_DIR/$thingino_fw_name" |cut -d' ' -f1 ) == $(cat "$SD_DIR/$thingino_fw_name.sha256sum" |tail -n 1 |cut -d' ' -f1 ) ]; then
    
    cd $SD_DIR

    $SD_DIR/uniflasher.sh $SD_DIR/$thingino_fw_name

    else
        echo "Update file might be corrupt."
        return 1
    fi

    if [ $(dd if=/dev/mtd0 bs=512 count=512 |sha256sum |cut -d' ' -f1 ) == $(dd if="$SD_DIR/$thingino_fw_name" bs=512 count=512 |sha256sum |cut -d' ' -f1) ]; then
        echo "New uboot Verivication success."
        return 0
    else
        echo "New uboot Verivication failed, something got wrong."
        return 1
    fi

    echo "Unknown error."
    return 1

}

thingino_import_iqfile() {
    sensor_name=$(dmesg | grep "info: success sensor find :" |tr ':' '\n' |tr ' ' '\0' |tail -n 1)
    SENSOR_IQ_FILE=$(ls $backup_dir/sensor |grep $sensor_name)
    back=$(echo $backup_dir |busybox tr '/' '\n' |busybox tail -n 1)
    if [ -z $SENSOR_IQ_FILE ];then
        echo "Can't find sensor iq file. something wrong."
        sleep $timeout
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















#Check for sensor and wifi module

# Check for sensor_jxk03_t31 in lsmod
lsmod | grep -q "^sensor_jxq03_t31"
found_jxk03_t31=$?

# Check for sensor_jxk04_t31 in lsmod
lsmod | grep -q "^sensor_jxk04_t31"
found_jxk04_t31=$?

# Check for sensor_jxk04_t31 in lsmod
lsmod | grep -q "^sensor_os03b10_t31"
found_os03b10_t31=$?

# Check for 8188fu in lsmod and usbid
lsmod | grep -q "^8188fu"
found_8188fu=$?
if [ $found_8188fu -eq 0 ]; then
    lsusb | grep -q "0bda:f179"
    found_8188fu=$?
fi

# Check for ssv6155 in lsmod and usbid
lsmod | grep -q "^ssv6x5x"
found_ssv6155=$?
if [ $found_ssv6155 -eq 0 ]; then
    lsusb | grep -q "8065:6000"
    found_ssv6155=$?
fi















#ET-N3431H-DW
if [ $Brand_Name == "ET-N3431H-DW" ]; then
    echo "find Elife ET-N3431H-DW "
    if [ $found_ssv6155 -eq 0 ] && [ $found_os03b10_t31 -eq 0 ]; then
        echo "find ET-N3431H-DW with ssv6155 and os03b10."
        uniflasher_update_fw "thingino-elife_etn3431hdw_t31x_os03b10_ssv6155.bin"
        if [ $? -eq 0 ]; then
            echo "ET-N3431H-DW update success. "
            thingino_import_iqfile
            reboot
            exit 0
        else
            echo "ET-N3431H-DW update fail. Please telnet it to see what happens" 
            sleep $timeout
        fi
    else
        echo "find ET-N3431H-DW ,but with different configuration."
            sleep $timeout
    fi

fi





echo "Other module $Brand_Name is found. Please telnet to see whats going on. "
sleep $timeout

