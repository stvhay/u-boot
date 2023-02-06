#!/bin/bash

bl31=rk3588_bl31_v1.28.elf
memspec=rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin

mkdir -p blobs
mkdir -p staging

make_uboot () {
    pushd blobs || exit 1
    rm -f * || exit 1
    wget  https://github.com/radxa/rkbin/raw/master/bin/rk35/${bl31} || exit 1
    wget  https://github.com/radxa/rkbin/raw/master/bin/rk35/${memspec} || exit 1
    popd || exit 1
    board=$1
    target=$2
    mkdir -p staging/${board} || exit 1
    make CROSS_COMPILE=aarch64-linux-gnu- mrproper || exit 1
    make CROSS_COMPILE=aarch64-linux-gnu- -j9 ${target} BL31=blobs/${bl31} spl/u-boot-spl.bin u-boot.dtb u-boot.itb || exit 1
    tools/mkimage -n rk3588 -d blobs/${memspec}:spl/u-boot-spl.bin staging/${board}/idbloader.img || exit 1
    mv -v u-boot.itb staging/${board}/ || exit 1
}

make_uboot orange-pi-5 orangepi_5_defconfig
make_uboot rock-5a rock-5a-rk3588s_defconfig
make_uboot rock-5b rock-5a-rk3588s_defconfig
make_uboot nanopi-r6 nanopi6_defconfig
