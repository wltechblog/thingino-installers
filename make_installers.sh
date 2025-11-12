#!/bin/bash
# Feb 2025, let's build sd card images instead of using zip files!
#
# globals
LOOP=""
WD=$(pwd)
trap cleanup SIGINT
mkdir -p tmp

cleanup() {
echo "Running cleanup"
cd ${WD}
sudo umount -q mnt
if [ $? = 0 ]
then
	sudo losetup -d ${LOOP}
fi
rm sd-base.img
}


new_image () {
if [ ! -e sd-base.img ]
then
	dd if=/dev/zero of=sd-base.img bs=1M count=120
	sfdisk sd-base.img < sd.fdisk
	LOOP=$(losetup -f)
	sudo losetup -P ${LOOP} sd-base.img 
	PART="${LOOP}p1"
	sudo mkfs.vfat -F 32 ${PART}
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

add_uboot() {
UBOOT=$1
get_asset https://github.com/gtxaspec/ingenic-u-boot-xburst1/releases/download/uboot-xb1-2025-09-11/${UBOOT}
sudo dd if=${WD}/tmp/${UBOOT} of=${LOOP} bs=512 seek=34 #add mmc recovery
rm ${UBOOT}
}

get_asset () {
TWD=$(pwd)

# If you need a previous release, add "-d yesterday" or similar to the next line
DAY=$(date +%Y-%m-%d)
FILE=$(echo $1 | sed "s|releases/latest/download|releases/download/firmware-${DAY}|")
FILE=$1
B=$(basename $FILE)
if [ ! -e ${WD}/tmp/${B} ]
then
	cd ${WD}/tmp
	wget -q $FILE
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
sudo umount -q mnt
sync
sudo losetup -d ${LOOP}
}
# cleanup past tasks
rm -rf mnt

do_wyze_v2() {
echo " ################### Let's create a Wyze V2 install image"
WD=$(pwd)
new_image
cd ${WD}/tmp
#get_asset https://github.com/gtxaspec/wyze-neos-upgrade/actions/runs/13273116581/artifacts/2574761777 -O installer.zip
unzip -o ../assets/wz-neos-upgrader.zip 
cd ${WD}/mnt
cp ${WD}/tmp/uImage.lzma-t20 factory_ZMC6tiIDQN
cp ${WD}/assets/demo.bin .
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam2_t20x_jxf22_rtl8189ftv.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam2_t20x_jxf23_rtl8189ftv.bin
cd ${WD}
close_image
zip -o wyze-cam-2/wyze-cam-2-sd.zip sd.img
rm sd.img
}

do_wyze_v3() {
echo " ################### Let's create a Wyze V3 install image"
new_image
cd ${WD}/tmp
unzip -o ../assets/wz-neos-upgrader.zip 
cd ${WD}/mnt
cp ${WD}/tmp/uImage.lzma-t31 factory_t31_ZMC6tiIDQN
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam3_t31al_gc2053_atbm6031.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam3_t31x_gc2053_atbm6031.bin
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_cam3_t31x_gc2053_rtl8189ftv.bin
cd ${WD}
close_image
zip -o wyze-cam-3/wyze-cam-3-sd.zip sd.img
rm sd.img
}

do_aobocam_a12() {
echo  "Let's create an Aobocam A12 install image"
new_image
cd ${WD}/mnt
mkdir thingino
cp ${WD}/assets/busybox-mipsel-linux-gnu thingino/busybox
cp ${WD}/assets/aobocam-a12-factory.sh t23_prod_eth_test
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-aobocam_a12_t23dl_jxh63p_txw901u.bin
mv thingino-aobocam_a12_t23dl_jxh63p_txw901u.bin autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t23dl_msc0.bin
close_image
zip -o aobocam-a12/aobocam-a12-sd.zip sd.img
rm sd.img
}

do_wuuk_y0510() {
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
}

do_wuuk_y0310() {
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
}

do_aosu_c5l() {
echo " ############### Let's create a AOSU image #####"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-aosu_c5l_t31l_sc3336_rtl8188ftv.bin
mv thingino-aosu_c5l_t31l_sc3336_rtl8188ftv.bin autoupdate-full.bin
cp autoupdate-full.bin FIRMWARE_C5L_F.bin
cd ${WD}
add_uboot u-boot-isvp_t31_msc0.bin
close_image
zip -o aosu-c5l/aosu-c5l-t31.zip sd.img
rm sd.img
}



do_wansview_g6() {
echo " ################### Let's create Wansview G6 2.4ghz install images"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wansview_g6_t31l_sc2336_atbm6012b.bin
mv thingino-wansview_g6_t31l_sc2336_atbm6012b.bin autoupdate-full.bin
add_uboot u-boot-isvp_t31_msc0.bin
cd ${WD}
close_image
zip -o wansview-g6/wansview-g6-2.4ghz-sd.zip sd.img
rm sd.img


echo " ####### Annnnnd the dual band...."
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wansview_g6_t31l_sc2336_ssv6256p.bin
mv thingino-wansview_g6_t31l_sc2336_ssv6256p.bin autoupdate-full.bin
add_uboot u-boot-isvp_t31_msc0.bin
cd ${WD}
close_image
zip -o wansview-g6/wansview-g6-dualband-sd.zip sd.img
rm sd.img
}


do_wansview_w7() {
echo " ################### Let's create Wansview W7/Galayou Y4 install images"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-galayou_y4_t23n_sc2336_atbm6062.bin
mv thingino-galayou_y4_t23n_sc2336_atbm6062.bin v4_all.bin
add_uboot u-boot-isvp_t23n_msc0.bin
cd ${WD}
close_image
zip -o wansview-w7/wansview-w7-t23-atbm6062-sd.zip sd.img
rm sd.img

new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-galayou_y4_t23n_sc2336_atbm6062cu.bin
mv thingino-galayou_y4_t23n_sc2336_atbm6062cu.bin v4_all.bin
add_uboot u-boot-isvp_t23n_msc0.bin
cd ${WD}
close_image
zip -o wansview-w7/wansview-w7-t23-atbm6062cu-sd.zip sd.img
rm sd.img


new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wansview_w7_t31l_sc2336_atbm6012b.bin
mv thingino-wansview_w7_t31l_sc2336_atbm6012b.bin v4_all.bin
add_uboot u-boot-isvp_t31_msc0_lite.bin

cd ${WD}
close_image
zip -o wansview-w7/wansview-w7-t31-atbm6012bsd.zip sd.img
rm sd.img
}


do_cinnado_d1() {
echo " ################### Let's create Cinnado D1 images"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-cinnado_d1_t23n_sc2336_atbm6012bx.bin
mv thingino-cinnado_d1_t23n_sc2336_atbm6012bx.bin autoupdate-full.bin
cp autoupdate-full.bin v4_all.bin
cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
close_image
zip -o cinnado-d1/cinnado-d1-t23n-atbm6012bx.zip sd.img
rm sd.img

new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-cinnado_d1_t31l_sc2336_atbm6031.bin
mv thingino-cinnado_d1_t31l_sc2336_atbm6031.bin v4_all.bin
cd ${WD}
close_image
zip -o cinnado-d1/cinnado-d1-t31l-atbm6031.zip sd.img
rm sd.img

new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-cinnado_d1_t31l_sc2336_atbm6031x.bin
mv thingino-cinnado_d1_t31l_sc2336_atbm6031x.bin v4_all.bin
cd ${WD}
close_image
zip -o cinnado-d1/cinnado-d1-t31l-atbm6031x.zip sd.img
rm sd.img
}

do_wyze_cp1() {
echo " ################### Let's create a Wyze Cam Pan V1 installer"
WD=$(pwd)
new_image
cd ${WD}/mnt
cp ${WD}/tmp/uImage.lzma-t20 factory_ZMC6tiIDQN
cp ${WD}/assets/demo.bin .
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_campan1_t20x_jxf22_rtl8189etv.bin
mv thingino-wyze_campan1_t20x_jxf22_rtl8189etv.bin autoupdate-full.yay
cd ${WD}
close_image
zip -o wyze-cam-pan-v1/wyze-cam-pan-v1-sd.zip sd.img
rm sd.img
}

do_wyze_cp2() {
echo " ################### Let's create a Wyze Cam Pan V2 instllaer"
WD=$(pwd)
new_image
cd ${WD}/mnt
cp ${WD}/tmp/uImage.lzma-t31 factory_t31_ZMC6tiIDQN
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-wyze_campan2_t31x_gc2053_atbm6031.bin
mv thingino-wyze_campan2_t31x_gc2053_atbm6031.bin autoupdate-full.yay
cd ${WD}
close_image
zip -o wyze-cam-pan-v2/wyze-cam-pan-v2-sd.zip sd.img
rm sd.img
}

do_sonoff_slim_gen2() {
echo " ################### Let's create a Sonoff Slim Gen2 installer"
WD=$(pwd)
new_image
cd ${WD}/mnt
cp ${WD}/assets/sonoff-slim-gen2-install.sh start_sfproducttest.sh
touch sfproducttest

get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-sonoff_s2_t23n_sc2336_atbm6012bx.bin
mv thingino-sonoff_s2_t23n_sc2336_atbm6012bx.bin autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
close_image
zip -o sonoff-slim-gen-2/sonoff-slim-gen-2-sd.zip sd.img
rm sd.img
}

do_jooan_q3r() {
echo " ################### Let's create Jooan Q3R Installers"
echo " #### Altobeam"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-jooan_q3r_t23n_sc1a4t_eth+atbm6012bx.bin
mv thingino-jooan_q3r_t23n_sc1a4t_eth+atbm6012bx.bin  autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
#add mmc recovery
close_image
zip -o jooan-q3r/jooan-q3r-u-altobeam-6012bx.zip sd.img
rm sd.img
}

do_jooan_a2r_u() {
echo " ################### Let's create Jooan A2R-U Installers"
echo " #### Altobeam"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-jooan_a2r_t23n_sc1a4t_atbm6012bx.bin
mv thingino-jooan_a2r_t23n_sc1a4t_atbm6012bx.bin autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
#add mmc recovery
close_image
zip -o jooan-a2r-u/jooan-a2r-u-altobeam-6012bx.zip sd.img
rm sd.img

echo " #### SSV"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-jooan_a2r_t23n_sc1a4t_ssv6355.bin
mv thingino-jooan_a2r_t23n_sc1a4t_ssv6355.bin autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
close_image
zip -o jooan-a2r-u/jooan-a2r-u-ssv6355.zip sd.img
rm sd.img
}

do_jooan_a6m_u() {
echo " ################### Let's create Jooan a6m-U Installers"
echo " #### Altobeam"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-jooan_a6m_t23n_sc1a4t_atbm6012bx.bin
mv thingino-jooan_a6m_t23n_sc1a4t_atbm6012bx.bin autoupdate-full.bin

cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
#add mmc recovery
close_image
zip -o jooan-a6m-u/jooan-a6m-u-altobeam-6012bx.zip sd.img
rm sd.img

echo " #### SSV"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-jooan_a6m_t23n_sc1a4t_ssv6355.bin
mv thingino-jooan_a6m_t23n_sc1a4t_ssv6355.bin autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
close_image
zip -o jooan-a6m-u/jooan-a6m-u-ssv6355.zip sd.img
rm sd.img
}


do_galayou_g7() {
echo " #### Galayou G7"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-galayou_g7_t23n_sc2336_atbm6012bx.bin
mv thingino-galayou_g7_t23n_sc2336_atbm6012bx.bin  autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
close_image
zip -o galayou-g7/galayou-g7.zip sd.img
rm sd.img
}

do_aoqee_c1() {
echo " #### aoqee-c1"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-aoqee_c1_t23n_sc2336_atbm6062.bin
mv thingino-aoqee_c1_t23n_sc2336_atbm6062.bin  autoupdate-full.bin
cp autoupdate-full.bin v4_all.bin
cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
close_image
zip -o aoqee-c1/aoqee-c1.zip sd.img
rm sd.img
}

do_galayou_g2() {
echo " #### Galayou G2"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-galayou_g2_t23n_sc2336_atbm6012bx.bin
mv thingino-galayou_g2_t23n_sc2336_atbm6012bx.bin autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
close_image
zip -o galayou-g2/galayou-g2-2k.zip sd.img
rm sd.img
}

do_tapo_c100() {
echo " #### tapo-c100 T23"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-tplink_tapo_c100_t23n_sc2336p_wq9001.bin
mv thingino-tplink_tapo_c100_t23n_sc2336p_wq9001.bin autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t23n_msc0.bin
close_image
zip -o tapo-c100/tapo-c100-t23.zip sd.img
rm sd.img

echo " #### tapo c-100 T31"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-tplink_tapo_c100_t31l_sc2336_rtl8188ftv.bin
mv thingino-tplink_tapo_c100_t31l_sc2336_rtl8188ftv.bin autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t31_msc0_lite.bin
close_image
zip -o tapo-c100/tapo-c100-t31.zip sd.img
rm sd.img


}


#thingino-szt_ct213_t23n_gc1084_atbm6012b.bin
# this is being developed still
#do_szt_ct213() {
#echo " #### szt-ct213"
#new_image
#cd ${WD}/mnt
#get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-szt_ct213_t23n_gc1084_atbm6012b.bin
#mv thingino-szt_ct213_t23n_gc1084_atbm6012b.bin  autoupdate-full.bin
#cd ${WD}
#add_uboot u-boot-isvp_t23n_msc0.bin
#close_image
#zip -o szt-ct213/szt-ct213.zip sd.img
#rm sd.img
#}


do_galayou_y4() {
echo " #### galayou y4"
new_image
cd ${WD}/mnt
get_asset https://github.com/themactep/thingino-firmware/releases/latest/download/thingino-galayou_y4_t31l_sc2336_atbm6032.bin
mv thingino-galayou_y4_t31l_sc2336_atbm6032.bin  autoupdate-full.bin
cd ${WD}
add_uboot u-boot-isvp_t31_msc0_lite.bin
close_image
zip -o wansview-w7/galayou-y4-t31l-sc2336-atbm6032.zip sd.img
rm sd.img
}

do_diagnostics() {
echo " ### diag"
new_image
cd ${WD}/mnt
cp ${WD}/assets/runonce.sh .
cd ${WD}
close_image
zip -o diagnostics/diagnostics.zip sd.img
rm sd.img
}

make_clean() {
rm tmp/*
}

make_all() {
for DO in $(grep "()" $0  | grep "^do_" | cut -f 1 -d '(')
do
	$DO
done
}

# Start
#set -x
if [ "$1" = "" ]
then
	echo "Usage:"
	echo "$0 [command]"
	echo "Available commands:"
	echo "all: build all images"
	echo "clean: remove all cached assets"
	echo 
	echo "Or, specify a target:"
	grep "()" $0  | grep "^do_" | cut -f 1 -d '(' | cut -b 4-
	exit
elif [ "$1" = "clean" ]
then
	make_clean
elif [ "$1" = "all" ]
then
	make_all
	cleanup
else
	DO="do_${1}"
	$DO
	cleanup
fi
