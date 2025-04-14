#!/bin/bash
# Feb 2025, let's build sd card images instead of using zip files!
#
# globals
LOOP=""

new_image () {
if [ ! -e sd-base.img ]
then
	dd if=/dev/zero of=sd-base.img bs=1M count=128
	sfdisk sd-base.img < sd.fdisk
	LOOP=$(losetup -f)
	sudo losetup -P ${LOOP} sd-base.img 
	PART="${LOOP}p1"
	sudo mkfs.vfat ${PART}
	sudo losetup -d ${LOOP}
fi
LOOP=$(losetup -f)
PART="${LOOP}p1"
cp sd-base.img sd.img
sudo losetup -P ${LOOP} sd.img 

mkdir -p mnt
ID=${UID}
sudo mount -o user,uid=${ID} ${PART} mnt
}

get_asset () {
TWD=$(pwd)
DAY=$(date +%Y-%m-%d -d yesterday)
FILE=$(echo $1 | sed "s|releases/latest/download|releases/download/firmware-${DAY}|")
# We need yesterday's build
#--2025-04-12 17:24:52--  https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam3_t31x_gc2053_atbm6031.bin
#Resolving github.com (github.com)... 140.82.113.4
#Connecting to github.com (github.com)|140.82.113.4|:443... connected.
#HTTP request sent, awaiting response... 302 Found
#Location: https://github.com/themactep/thingino-firmware/releases/download/firmware-2025-04-12/thingino-wyze_cam3_t31x_gc2053_atbm6031.bin [following]
#--2025-04-12 17:24:52--  https://github.com/themactep/thingino-firmware/releases/download/firmware-2025-04-12/thingino-wyze_cam3_t31x_gc2053_atbm6031.bin

B=$(basename $FILE)
if [ ! -e ${WD}/tmp/${B} ]
then
	cd ${WD}/tmp
	wget $FILE
	if [ $? != 0 ] || [ ! -s ${B} ]
	then
		echo "Couldn't download $1"
		exit
	fi
	cd ${TWD}
fi
cp ${WD}/tmp/${B} .
}

close_image () {
ls -lR mnt
sudo umount mnt
sync
sudo losetup -d ${LOOP}
}
# cleanup past tasks
rm -rf mnt

echo " ################### Let's create a Wyze V2 install image"
WD=$(pwd)
new_image
mkdir ${WD}/tmp
cd ${WD}/tmp
#get_asset https://github.com/gtxaspec/wyze-neos-upgrade/actions/runs/13273116581/artifacts/2574761777 -O installer.zip
unzip -o ../assets/wz-neos-upgrader.zip 
cd ${WD}/mnt
cp ${WD}/tmp/uImage.lzma-t20 factory_ZMC6tiIDQN
cp ${WD}/assets/demo.bin .
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam2_t20x_jxf22_rtl8189ftv.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam2_t20x_jxf23_rtl8189ftv.bin
mv thingino-wyze_cam2_t20x_jxf22_rtl8189ftv.bin thingino-wyze_c2_jxf22.bin
mv thingino-wyze_cam2_t20x_jxf23_rtl8189ftv.bin thingino-wyze_c2_jxf23.bin
cd ${WD}
close_image
zip -o wyze-cam-2/wyze-cam-2-sd.zip sd.img
rm sd.img

echo " ################### Let's create a Wyze V3 install image"
new_image
cd ${WD}/mnt
cp ${WD}/tmp/uImage.lzma-t31 factory_t31_ZMC6tiIDQN
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam3_t31al_gc2053_atbm6031.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam3_t31x_gc2053_atbm6031.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam3_t31x_gc2053_rtl8189ftv.bin
mv thingino-wyze_cam3_t31al_gc2053_atbm6031.bin thingino-wyze_c3_t31al_atbm.bin
mv thingino-wyze_cam3_t31x_gc2053_atbm6031.bin thingino-wyze_c3_t31x_atbm.bin
mv thingino-wyze_cam3_t31x_gc2053_rtl8189ftv.bin thingino-wyze_c3_t31x_rtl.bin
cd ${WD}
close_image
zip -o wyze-cam-3/wyze-cam-3-sd.zip sd.img
rm sd.img

echo  "Let's create a Wuuk Y0510 install image"
new_image
cd ${WD}/mnt
mkdir FACTORY
cd FACTORY
cp ${WD}/assets/wuuk-y0510-factory.sh factory_install.sh
cd ${WD}/mnt/
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wuuk_y0510_t31x_sc401ai_ssv6158.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wuuk_y0510_t31x_sc4336p_ssv6158.bin
cd ${WD}
close_image
zip -o wuuk-y0510/wuuk-y0510-sd.zip sd.img
rm sd.img

echo " ################### Let's create a Wuuk Y0310 install iomage"
new_image
cd ${WD}/mnt
mkdir FACTORY
cd FACTORY
cp ${WD}/assets/wuuk-y0310-factory.sh factory_install.sh
cd ${WD}/mnt/
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wuuk_y0310_t31x_sc401ai_ssv6158.bin
cd ${WD}
close_image
zip -o wuuk-y0310/wuuk-y0310-sd.zip sd.img
rm sd.img

echo " ################### Let's create Wansview W7/Galayou Y4 install images"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-galayou_y4_t23n_sc2336_atbm6062.bin
mv thingino-galayou_y4_t23n_sc2336_atbm6062.bin v4_all.bin
cd ${WD}
close_image
zip -o wansview-w7/wansview-w7-t23-sd.zip sd.img
rm sd.img

new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wansview_w7_t31l_sc2336_atbm6012b.bin
mv thingino-wansview_w7_t31l_sc2336_atbm6012b.bin v4_all.bin
cd ${WD}
close_image
zip -o wansview-w7/wansview-w7-t31-sd.zip sd.img
rm sd.img


echo " ################### Let's create Cinnado D1 images"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-cinnado_d1_t23n_sc2336_atbm6012bx.bin
get_asset https://github.com/gtxaspec/ingenic-u-boot-xburst1/releases/download/uboot-xb1-2025-03-10/u-boot-isvp_t23n_msc0.bin
mv thingino-cinnado_d1_t23n_sc2336_atbm6012bx.bin autoupdate-full.bin
cd ${WD}
sudo dd if=tmp/u-boot-isvp_t23n_msc0.bin of=${LOOP} bs=512 seek=34 #add mmc recovery
close_image
zip -o cinnado-d1/cinnado-d1-t23.zip sd.img
rm sd.img

new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-cinnado_d1_t31l_sc2336_atbm6031.bin
mv thingino-cinnado_d1_t31l_sc2336_atbm6031.bin v4_all.bin
cd ${WD}
close_image
zip -o cinnado-d1/cinnado-d1-t31.zip sd.img
rm sd.img

echo " ################### Let's create a Wyze Cam Pan V1 installer"
WD=$(pwd)
new_image
cd ${WD}/mnt
cp ${WD}/tmp/uImage.lzma-t20 factory_ZMC6tiIDQN
cp ${WD}/assets/demo.bin .
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_campan1_t20x_jxf22_rtl8189etv.bin
mv thingino-wyze_campan1_t20x_jxf22_rtl8189etv.bin autoupdate-full.bin
cd ${WD}
close_image
zip -o wyze-cam-pan-v1/wyze-cam-pan-v1-sd.zip sd.img
rm sd.img


echo " ################### Let's create a Wyze Cam Pan V2 instllaer"
WD=$(pwd)
new_image
cd ${WD}/mnt
cp ${WD}/tmp/uImage.lzma-t31 factory_t31_ZMC6tiIDQ
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_campan2_t31x_gc2053_atbm6031.bin
mv thingino-wyze_campan2_t31x_gc2053_atbm6031.bin autoupdate-full.bin
cd ${WD}
close_image
zip -o wyze-cam-pan-v2/wyze-cam-pan-v2-sd.zip sd.img
rm sd.img

echo " ################### Let's create a Sonoff Slim Gen2 installer"
WD=$(pwd)
new_image
cd ${WD}/mnt
cp ${WD}/assets/sonoff-slim-gen2-install.sh start_sfproducttest.sh
touch sfproducttest

get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-sonoff_s2_t23n_sc2336_atbm6012bx.bin
mv thingino-sonoff_s2_t23n_sc2336_atbm6012bx.bin autoupdate-full.bin
cd ${WD}
close_image
zip -o sonoff-slim-gen-2/sonoff-slim-gen-2-sd.zip sd.img
rm sd.img

echo " ################### Let's create Jooan A2R-U Installers"
echo " #### Altobeam"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-jooan_a2r_t23n_sc1a4t_atbm6012bx.bin
get_asset https://github.com/gtxaspec/ingenic-u-boot-xburst1/releases/download/uboot-xb1-2025-03-10/u-boot-isvp_t23n_msc0.bin
mv thingino-jooan_a2r_t23n_sc1a4t_atbm6012bx.bin autoupdate-full.bin
cd ${WD}
sudo dd if=tmp/u-boot-isvp_t23n_msc0.bin of=${LOOP} bs=512 seek=34
#add mmc recovery
close_image
zip -o jooan-a2r-u/jooan-a2r-u-altobeam-6012bx.zip sd.img
rm sd.img

echo " #### SSV"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-jooan_a2r_t23n_sc1a4t_ssv6355.bin
get_asset https://github.com/gtxaspec/ingenic-u-boot-xburst1/releases/download/uboot-xb1-2025-03-10/u-boot-isvp_t23n_msc0.bin
mv thingino-jooan_a2r_t23n_sc1a4t_ssv6355.bin autoupdate-full.bin
cd ${WD}
sudo dd if=tmp/u-boot-isvp_t23n_msc0.bin of=${LOOP} bs=512 seek=34
#add mmc recovery
close_image
zip -o jooan-a2r-u/jooan-a2r-u-ssv6355.zip sd.img
rm sd.img

echo " #### Galayou G7"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-galayou_g7_t23n_sc2336_atbm6012bx.bin
get_asset https://github.com/gtxaspec/ingenic-u-boot-xburst1/releases/download/uboot-xb1-2025-03-10/u-boot-isvp_t23n_msc0.bin
mv thingino-galayou_g7_t23n_sc2336_atbm6012bx.bin  autoupdate-full.bin
cd ${WD}
sudo dd if=tmp/u-boot-isvp_t23n_msc0.bin of=${LOOP} bs=512 seek=34 #add mmc recovery
close_image
zip -o galayou-g7/galayou-g7.zip sd.img
rm sd.img

echo " #### aoqee-c1"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-aoqee_c1_t23n_sc2336_atbm6062.bin
get_asset https://github.com/gtxaspec/ingenic-u-boot-xburst1/releases/download/uboot-xb1-2025-03-10/u-boot-isvp_t23n_msc0.bin
mv thingino-aoqee_c1_t23n_sc2336_atbm6062.bin  autoupdate-full.bin
cd ${WD}
sudo dd if=tmp/u-boot-isvp_t23n_msc0.bin of=${LOOP} bs=512 seek=34 #add mmc recovery
close_image
zip -o aoqee-c1/aoqee-c1.zip sd.img
rm sd.img


echo " #### galayou y4"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-galayou_y4_t31l_sc2336_atbm6032.bin
get_asset https://github.com/gtxaspec/ingenic-u-boot-xburst1/releases/download/uboot-xb1-2025-04-07/u-boot-isvp_t31_msc0_lite.bin
mv thingino-galayou_y4_t31l_sc2336_atbm6032.bin  autoupdate-full.bin
cd ${WD}
sudo dd if=tmp/u-boot-isvp_t31_msc0_lite.bin  of=${LOOP} bs=512 seek=34 #add mmc recovery
close_image
zip -o galayou-y4/galayou-y4-t31l-sc2336-atbm6032.zip sd.img
rm sd.img

