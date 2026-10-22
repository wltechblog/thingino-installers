#!/bin/ash

audio_enable=0

timeout=0

#can't sleep when audio_enable=1 ,if sleep, it will auto reboot after killing aoni_ipc and socket_system_server.
if [ $audio_enable -eq 0 ] ;then
    sleep 30
    #sometimes backup fails because some app is writing to mtd.
fi
#no flash, only backup:1 enable flash:0
backup_only=1


CONFIG_FILE="/mnt/mtd/SystemConfig.ini"
SD_DIR="/mnt/sd_card"

# Extract MAC address (assumes line like: Mac = 00:12:34:56:78:90)
MAC=$(grep -i "^Mac" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' \r\n' | tr ':' '_' )
if [ -z "$MAC" ]; then
    echo "MAC address not found!" >> "$SD_DIR/error"
    exit 1
fi

# Extract Product_DEVICE_TYPE
Product_DEVICE_TYPE=$(grep -i "^Product_DEVICE_TYPE" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' \r\n' )
if [ -z "$Product_DEVICE_TYPE" ]; then
    echo "Product_DEVICE_TYPE not found!" >> "$SD_DIR/error"
    exit 1
fi


# Create directory path
DIR="$SD_DIR/H3C_$MAC"
mkdir -p "$DIR"



##kill aoni_ipc socket_system_server
#There is no audio if we don't kill it.
#it has to be killed very early when boot,or the system will auto reboot.
echo $Product_DEVICE_TYPE |grep -q "^T31_"
found_t31=$?
if [ $found_t31 -eq 0 ] && [ $audio_enable -eq 1 ] && [ ! -e /mnt/sd_card/rebooted ] ; then
    echo "killing aoni_ipc and socket_system_server "
    killall -9 aoni_ipc  socket_system_server
    udhcpc -x hostname:H3C -b -i eth0 -n -s /mnt/mtd/udhcpc/default.script    
    /mnt/sd_card/audioplay_t31  /mnt/sd_card/greet.wav 80 &
    touch /mnt/sd_card/rebooted ##sometimes the watchdog will make it reboot about one minute after these process being killed. I still don't know how to solve this. It will auto reboot when its sigmagstar. But I have tested if it's ingenic and being killed early, it won't auto reboot. So I can't make a sigmastar auto installer unless someone compile a sigmastar uboot that support something like autoupdate-full.bin becaue it could reboot during the writing process. 
fi








##wifi

if [ ! -e  /mnt/sd_card/wpa_h3c.conf ];then
cat <<EOF > /mnt/sd_card/wpa_h3c.conf
ctrl_interface=/run/wpa_supplicant
ap_scan=2

network={
        ssid="H3C-AP"
        mode=2
        #psk="installer"
        psk=5896ca5200c52bb1efef64df61f4bedc8b1c4168f41a02470be426ead0e38714
}
EOF
fi

if [ ! -e  /mnt/sd_card/udhcpd-h3c.conf ];then
cat <<EOF > /mnt/sd_card/udhcpd-h3c.conf
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


killall -9 wpa_supplicant
wpa_supplicant  -i wlan0 -c /mnt/sd_card/wpa_h3c.conf -B
ifconfig wlan0 172.16.0.1 netmask 255.255.255.0 &
udhcpd /mnt/sd_card/udhcpd-h3c.conf &















#Backup

#echo "Backing up MTD devices to $DIR ..."
#for DEV in /dev/mtd[0-9]*; do
#    if [ -c "$DEV" ]; then
#    NAME=$(basename "$DEV")
#    OUTFILE="$DIR/${NAME}.bin"
#        echo "Backing up $DEV -> $OUTFILE"
#        dd if="$DEV" of="$OUTFILE" 
#    fi
#done

echo "Backup logs to $DIR ..."
dmesg > "$DIR/dmesg.log"
mount -t debugfs none /sys/kernel/debug
cat /sys/kernel/debug/gpio > "$DIR/gpio.log"
mount > "$DIR/mount.log"
cp "$CONFIG_FILE" "$DIR"

cp -r /mnt/mtd/isvp_service/iqfile/ "$DIR"
##tar -czvf "$DIR.tar.gz" "$DIR"
##tftp -p -l "$DIR.tar.gz" -r "H3C_$MAC.tar.gz" 192.168.xx.xx

















# Function to generate a backup directory
generate_backup_dir() {
  #base_dir="/mnt"
  #template="$base_dir/ORIG_BACKUP_XXXXXX"

  # Create a unique temporary directory
  #backup_dir=$(mktemp -d -p "$base_dir" "ORIG_BACKUP_XXXXXX" 2>/dev/null)
  #if [ -z "$backup_dir" ]; then
  #  echo "Error: Unable to create a unique directory in $base_dir."
  #  tell "Error: Unable to create a unique directory in $base_dir."
  #  exit 1
  #fi
  backup_dir=$DIR
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
        exit 1
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
        echo "$status"
        exit 1
    else
        return 0
    fi
}




backup_mtd_partitions

if [ $? -eq 0 ]; then
    echo "Backup success."
else
    echo "Backup failed." 
    echo "Backup failed." >> "$SD_DIR/error"
    exit 1
fi


if [ $backup_only -eq 1 ]; then
    echo "Flashing disabled."
    echo "Flashing disabled." >> "$SD_DIR/error"
    exit 0
else
    echo "Flashing enabled."
fi



#Check for sensor and wifi module

# Check for sensor_jxk04_t31 in lsmod
lsmod | grep -q "^sensor_jxk04_t31"
found_jxk04_t31=$?


# Check for sensor_jxk03_t31 in lsmod
lsmod | grep -q "^sensor_jxq03_t31"
found_jxk03_t31=$?

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





##thingino_update_fw: Check image checksum, erase and write uboot to mtd0, copy right firmware to autoupdate-full.bin
thingino_update_fw() {
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
    if [ ! -f "$SD_DIR/$thingino_fw_name.uboot" ]; then
        echo "Firmware file $thingino_fw_name.uboot does not exist." 
        return 1
    fi
    if [ ! -f "$SD_DIR/$thingino_fw_name.uboot.sha256sum" ]; then
        echo "Firmware checksum $thingino_fw_name.uboot.sha256sum does not exist." 
        return 1
    fi

    cp "$SD_DIR/$thingino_fw_name" "$SD_DIR/autoupdate-full.bin"
    fwcopy=$?
    sync

    if [ $fwcopy -eq 0 ] && [ $(sha256sum  "$SD_DIR/autoupdate-full.bin" |cut -d' ' -f1 ) == $(cat "$SD_DIR/$thingino_fw_name.sha256sum" |tail -n 1 |cut -d' ' -f1 ) ] && [ $(sha256sum  "$SD_DIR/$thingino_fw_name.uboot" |cut -d' ' -f1 ) == $(cat "$SD_DIR/$thingino_fw_name.uboot.sha256sum" |tail -n 1 |cut -d' ' -f1 ) ]; then
        flash_eraseall /dev/mtd0
	flashcp -v "$SD_DIR/$thingino_fw_name.uboot" /dev/mtd0
	##the "dd if="$SD_DIR/autoupdate-full.bin" bs=512 count=512 of=/dev/mtd0" would completely brick the device for new uboot, because it's 320k not 256k
        ##dd if="$SD_DIR/autoupdate-full.bin" bs=512 count=512 of=/dev/mtd0
        sync
        echo "Uboot is written."
        rm $SD_DIR/autoupdate-full.done
	return 0
    else
        echo "Update file might be corrupt."
        return 1
    fi

    #if [ $(dd if=/dev/mtd0 bs=512 count=512 |sha256sum |cut -d' ' -f1 ) == $(dd if="$SD_DIR/autoupdate-full.bin" bs=512 count=512 |sha256sum |cut -d' ' -f1) ]; then
        #echo "New uboot Verivication success."
        #return 0
    #else
        #echo "New uboot Verivication failed, something got wrong."
        #return 1
    #fi

    echo "Unknown error."
    return 1

}



thingino_import_iqfile() {
    rm $SD_DIR/runonce.sh
    SENSOR_IQ_FILE=$(ls $DIR/iqfile |grep .bin)
    echo "mkdir -p /etc/sensor /opt/sensor " >> $SD_DIR/runonce.sh
    echo "cp /mnt/mmcblk0p1/H3C_$MAC/iqfile/$SENSOR_IQ_FILE /opt/sensor/uploaded.bin " >> $SD_DIR/runonce.sh
    echo "ln -sf /opt/sensor/uploaded.bin /etc/sensor/$SENSOR_IQ_FILE " >> $SD_DIR/runonce.sh
    rm $SD_DIR/runonce.done
    sync
}







#C2041
if [ $Product_DEVICE_TYPE == "T31_E95AJ2J_CFG" ]; then
    echo "find H3C C2041"
    if [ $found_8188fu -eq 0 ] && [ $found_jxk04_t31 -eq 0 ]; then
        echo "find C2041 with rtl8188ftv and jxk04." >> "$DIR/h3c_thingino_update_log"
        thingino_update_fw "thingino-h3c_c2041_t31x_jxk04_eth+rtl8188ftv.bin"
        if [ $? -eq 0 ]; then
            echo "C2041 uboot update success."
            thingino_import_iqfile
            sleep $timeout
            reboot
            exit 0
        else
            echo "C2041 update fail." >> "$SD_DIR/error"
            exit 1
        fi
    else
        echo "find C2041 ,but with different configuration." >> "$SD_DIR/error"
            exit 1
    fi

fi





#tc2100
if [ $Product_DEVICE_TYPE == "T31_E95AJ6H_CFG" ]; then
    echo "find H3C TC2100_V2.0 "
    if [ $found_ssv6155 -eq 0 ] && [ $found_jxk03_t31 -eq 0 ]; then
        echo "find TC2100 with ssv6155 and jxq03." >> "$DIR/h3c_thingino_update_log"
        thingino_update_fw "thingino-h3c_tc2100_t31n_jxq03_eth+ssv6155.bin"
        if [ $? -eq 0 ]; then
            echo "TC2100 uboot update success."
            thingino_import_iqfile
            sleep $timeout
            reboot
            exit 0
        else
            echo "TC2100 update fail." >> "$SD_DIR/error"
            exit 1
        fi
    else
        echo "find TC2100 ,but with different configuration." >> "$SD_DIR/error"
            exit 1
    fi

fi




if [ $Product_DEVICE_TYPE == "T31_E97VJ6H_CFG" ]; then
    echo "find H3C TC3110_V2.0 "  >> "$SD_DIR/error"
    exit 1
fi

if [ $Product_DEVICE_TYPE == "T31_E97VJ5G_CFG" ]; then
    echo "find H3C C3141 "  >> "$SD_DIR/error"
    exit 1
fi



#SigmaStar
if [ $Product_DEVICE_TYPE == "SSC335_E95AM2K_CFG" ] || [ $Product_DEVICE_TYPE == "SSC335_E95AM2H_E_CFG" ]; then
    echo "find TC2100 ,but using SigmaStar, no thingino available"  >> "$SD_DIR/error"
    exit 1
fi

if [ $Product_DEVICE_TYPE == "SSC335_E97VM2K_CFG" ] || [ $Product_DEVICE_TYPE == "SSC335_E97VM2H_E_CFG" ] || [ $Product_DEVICE_TYPE == "SSC335_E97GM2H_CFG" ] ; then
    echo "find TC3110 ,but using SigmaStar, no thingino available"  >> "$SD_DIR/error"
    exit 1
fi



echo "Product_DEVICE_TYPE=$Product_DEVICE_TYPE is unknown "  >> "$SD_DIR/error"
exit 1

