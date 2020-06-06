#!/bin/bash

## Read configuration values
. ./build.conf

if [ -d ${BASE_DIR}/${WORK_DIR} ]
then
    echo "Please ensure that \"${WORK_DIR}\" directory does not exist"
    exit -1
fi

## Install the required packages
sudo apt-get -y --no-install-recommends --fix-missing install ${REQ_PKGS}

## Create directories
mkdir -p ${WORK_DIR}/packages
mkdir -p ${WORK_DIR}/${TOOLCHAIN[0]}
mkdir -p ${WORK_DIR}/${KERNEL[0]}
mkdir -p ${WORK_DIR}/${UBOOT[0]}


## Download all the required artifacts
wget ${TOOLCHAIN[1]} -O ${WORK_DIR}/packages/${TOOLCHAIN[0]} -q
wget ${KERNEL[1]} -O ${WORK_DIR}/packages/${KERNEL[0]} -q
wget ${UBOOT[1]} -O ${WORK_DIR}/packages/${UBOOT[0]} -q


## Extract various artifacts
tar --strip-components=1 -x -f ${WORK_DIR}/packages/${TOOLCHAIN[0]} -C ${WORK_DIR}/${TOOLCHAIN[0]}
tar --strip-components=1 -x -f ${WORK_DIR}/packages/${KERNEL[0]} -C ${WORK_DIR}/${KERNEL[0]}
tar --strip-components=1 -x -f ${WORK_DIR}/packages/${UBOOT[0]} -C ${WORK_DIR}/${UBOOT[0]}

## Compile kernel, modules and device tree
cd ${WORK_DIR}/${KERNEL[0]}

make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} sun8iw7p1smp_defconfig
make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} menuconfig
make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} zImage

make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} modules
make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_PATH=${INSTALL_MOD_PATH} modules_install

make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_PATH=${INSTALL_MOD_PATH} -C ${KSRC} M=xradio-master modules
make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_PATH=${INSTALL_MOD_PATH} -C ${KSRC} M=xradio-master modules_install

make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} dtbs
make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} dtbs_install


## Compile u-boot
cd ${WORK_DIR}/${UBOOT[0]}

make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} orangepi_zero_defconfig

make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} menuconfig

make -j4 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE}

