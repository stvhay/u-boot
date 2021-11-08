#!/bin/bash

bl31=rk3588_bl31_v1.28.elf
memspec=rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin

mkdir -p blobs
mkdir -p staging

make_uboot () {
    board=$1
    target=$2
    make CROSS_COMPILE=aarch64-linux-gnu- mrproper || exit 1

    pushd blobs || exit 1
    rm -f * || exit 1
    wget  https://github.com/radxa/rkbin/raw/master/bin/rk35/${bl31} || exit 1
    wget  https://github.com/radxa/rkbin/raw/master/bin/rk35/${memspec} || exit 1
    ../rkbin/tools/ddrbin_tool -g gen_param.txt ${memspec}
    sed -ie 's/\(uart baudrate\=\).*/\1115200/' gen_param.txt
    cp ${memspec}{,.backup}
    ../rkbin/tools/ddrbin_tool gen_param.txt ${memspec}
    popd || exit 1

    mkdir -p staging/${board} || exit 1
    make CROSS_COMPILE=aarch64-linux-gnu- -j9 ${target} BL31=blobs/${bl31} spl/u-boot-spl.bin u-boot.dtb u-boot.itb || exit 1
    tools/mkimage -n rk3588 -T rksd -d blobs/${memspec}:spl/u-boot-spl.bin staging/${board}/idbloader.img || exit 1
    mv -v u-boot.itb staging/${board}/ || exit 1
}

git clone https://github.com/rockchip-linux/rkbin.git

make_uboot orangepi-5 orangepi_5_defconfig
make_uboot rock-5a rock-5a-rk3588s_defconfig
make_uboot rock-5b rock-5a-rk3588s_defconfig
make_uboot nanopi-r6 nanopi6_defconfig
