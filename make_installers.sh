#!/bin/bash
# Feb 2025, let's build sd card images instead of using zip files!
#
# globals
LOOP=""

new_image () {
dd if=/dev/zero of=sd.img bs=1M count=128
sfdisk sd.img < sd.fdisk
LOOP=$(losetup -f)
sudo losetup -P ${LOOP} sd.img 
PART="${LOOP}p1"
sudo mkfs.vfat ${PART}
mkdir -p mnt
ID=${UID}
sudo mount -o user,uid=${ID} ${PART} mnt
}

get_asset () {
TWD=$(pwd)
B=$(basename $1)
if [ ! -e ${WD}/tmp/${B} ]
then
	cd ${WD}/tmp
	wget $1
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
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_c2_jxf22.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_c2_jxf23.bin
cd ${WD}
close_image
zip -o wyze-cam-2/wyze-cam-2-sd.zip sd.img
rm sd.img

echo " ################### Let's create a Wyze V3 install image"
new_image
cd ${WD}/mnt
cp ${WD}/tmp/uImage.lzma-t31 factory_t31_ZMC6tiIDQN
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_c3_t31al_atbm.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_c3_t31x_atbm.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_c3_t31x_rtl.bin
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
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wuuk_y0510_sc401ai.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wuuk_y0510_sc4336p.bin
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
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wuuk_y0310_sc401ai.bin
cd ${WD}
close_image
zip -o wuuk-y0310/wuuk-y0310-sd.zip sd.img
rm sd.img

echo " ################### Let's create Wansview W7/Galayou Y4 install images"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-galayou_y4_t23n_atbm6062.bin
mv thingino-galayou_y4_t23n_atbm6062.bin v4_all.bin
cd ${WD}
close_image
zip -o wansview-w7/wansview-w7-t23-sd.zip sd.img
rm sd.img

new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wansview_w7_t31l_atbm6012b.bin
mv thingino-wansview_w7_t31l_atbm6012b.bin v4_all.bin
cd ${WD}
close_image
zip -o wansview-w7/wansview-w7-t31-sd.zip sd.img
rm sd.img


echo " ################### Let's create Cinnado D1 images"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-cinnado_d1_t23n.bin
get_asset https://github.com/gtxaspec/ingenic-u-boot-xburst1/releases/download/uboot-xb1-2025-03-10/u-boot-isvp_t23n_msc0.bin
mv thingino-cinnado_d1_t23n.bin autoupdate-full.bin
cd ${WD}
sudo dd if=tmp/u-boot-isvp_t23n_msc0.bin of=${LOOP} bs=512 seek=34 #add mmc recovery
close_image
zip -o cinnado-d1/cinnado-d1-t23.zip sd.img
rm sd.img

new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-cinnado_d1_t31l.bin
mv thingino-cinnado_d1_t31l.bin v4_all.bin
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
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cp1.bin
mv thingino-wyze_cp1.bin autoupdate-full.bin
cd ${WD}
close_image
zip -o wyze-cam-pan-v1/wyze-cam-pan-v1-sd.zip sd.img
rm sd.img


echo " ################### Let's create a Wyze Cam Pan V2 instllaer"
WD=$(pwd)
new_image
cd ${WD}/mnt
cp ${WD}/tmp/uImage.lzma-t31 factory_t31_ZMC6tiIDQN
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cp2.bin
mv thingino-wyze_cp2.bin autoupdate-full.bin
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
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-sonoff_s2_t23n_atbm6012bx.bin
mv thingino-sonoff_s2_t23n_atbm6012bx.bin autoupdate-full.bin
cd ${WD}
close_image
zip -o sonoff-slim-gen-2/sonoff-slim-gen-2-sd.zip sd.img
rm sd.img

echo " ################### Let's create Jooan A2R-U Installers"
echo " #### Altobeam"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-jooan_a2r_atbm6012bx.bin
get_asset https://github.com/gtxaspec/ingenic-u-boot-xburst1/releases/download/uboot-xb1-2025-03-10/u-boot-isvp_t23n_msc0.bin
mv thingino-jooan_a2r_atbm6012bx.bin autoupdate-full.bin
cd ${WD}
sudo dd if=tmp/u-boot-isvp_t23n_msc0.bin of=${LOOP} bs=512 seek=34 #add mmc recovery
close_image
zip -o jooan-a2r-u/jooan-a2r-u-altobeam-6012bx.zip sd.img
rm sd.img

echo " #### SSV"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-jooan_a2r_ssv6355.bin
get_asset https://github.com/gtxaspec/ingenic-u-boot-xburst1/releases/download/uboot-xb1-2025-03-10/u-boot-isvp_t23n_msc0.bin
mv thingino-jooan_a2r_ssv6355.bin autoupdate-full.bin
cd ${WD}
sudo dd if=tmp/u-boot-isvp_t23n_msc0.bin of=${LOOP} bs=512 seek=34 #add mmc recovery
close_image
zip -o jooan-a2r-u/jooan-a2r-u-ssv6355.zip sd.img
rm sd.img

