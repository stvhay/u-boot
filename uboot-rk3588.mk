################################################################################
#
# uboot-rk3588
#
################################################################################

UBOOT_RK3588_VERSION = 5753b21aa92481ec3191fdf1f4d53274590ac5aa
UBOOT_RK3588_SITE = https://github.com/radxa/u-boot
UBOOT_RK3588_SITE_METHOD=git
UBOOT_RK3588_DEPENDS = host-python2
UBOOT_RK3588_LICENSE = GPL + Rockchip Proprietary (Extra Downloads)

# u-boot build parameters
UBOOT_RK3588_BL31 = rk3588_bl31_v1.28.elf
UBOOT_RK3588_MEMSPEC = rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin

# vendor blobs
UBOOT_RK3588_EXTRA_DOWNLOADS += https://github.com/radxa/rkbin/raw/master/bin/rk35/$(UBOOT_RK3588_BL31)
UBOOT_RK3588_EXTRA_DOWNLOADS += https://github.com/radxa/rkbin/raw/master/bin/rk35/$(UBOOT_RK3588_MEMSPEC)

UBOOT_RK3588_PKG_LOADER = spl/u-boot-spl.bin
UBOOT_RK3588_PKG_BL31 = $(UBOOT_RK3588_DL_DIR)/$(UBOOT_RK3588_BL31)
UBOOT_RK3588_PKG_MEMSPEC = $(UBOOT_RK3588_DL_DIR)/$(UBOOT_RK3588_MEMSPEC)

# board/defconfig pairs
UBOOT_RK3588_BUILDPAIR += orangepi-5/orangepi_5_defconfig
UBOOT_RK3588_BUILDPAIR += rock-5a/rock-5a-rk3588s_defconfig
UBOOT_RK3588_BUILDPAIR += rock-5b/rock-5b-rk3588_defconfig
UBOOT_RK3588_BUILDPAIR += nanopi-r6/nanopi6_defconfig

define UBOOT_RK3588_BUILD_BOOTLOADER
	$(eval board_defconfig = $(subst /, ,$(pair)))
	$(eval board = $(word 1, $(board_defconfig)))
	$(eval defconfig = $(word 2, $(board_defconfig)))
	@echo
	@echo ---- Building $(board) ----
	$(MAKE) -C $(@D) mrproper
	$(MAKE) -C $(@D) -j $(shell nproc) CROSS_COMPILE=$(TARGET_CROSS) $(defconfig) BL31=$(UBOOT_RK3588_PKG_BL31) $(UBOOT_RK3588_PKG_LOADER) u-boot.dtb u-boot.itb
	@echo -- Checking Files for mkiamge
	sha256sum $(UBOOT_RK3588_PKG_BL31)
	sha256sum $(UBOOT_RK3588_PKG_MEMSPEC)
	sha256sum $(@D)/$(UBOOT_RK3588_PKG_LOADER)
	$(@D)/tools/mkimage -n rk3588 -T rksd -d $(UBOOT_RK3588_PKG_MEMSPEC):$(@D)/$(UBOOT_RK3588_PKG_LOADER) $(@D)/idbloader.img
	sha256sum $(@D)/u-boot.itb
	sha256sum $(@D)/idbloader.img
	mkdir -p $(@D)/staging/$(board)
	cp -v $(@D)/u-boot.itb $(@D)/staging/$(board)/
	cp -v $(@D)/idbloader.img $(@D)/staging/$(board)/
endef

define UBOOT_RK3588_BUILD_CMDS
	mkdir -p $(@D)/staging
	$(foreach pair, $(UBOOT_RK3588_BUILDPAIR), $(UBOOT_RK3588_BUILD_BOOTLOADER))
endef

define UBOOT_RK3588_INSTALL_TARGET_CMDS
	cp -rv $(@D)/staging/* $(BINARIES_DIR)
endef

$(eval $(generic-package))
