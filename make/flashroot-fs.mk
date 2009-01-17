$(flashprefix)/root-cramfs: bootstrap $(hostprefix)/bin/mkimage
	rm -rf $@
if KERNEL26
	m4 --define=rootfs=cramfs --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_CRAMFS[= ].*$$/CONFIG_CRAMFS=y/' $(IDE_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(NFSSERVER_SED_CONF) $(LZMA_SED_CONF) $(flash_kernel_conf) > $(KERNEL_DIR)/.config
else
	m4 --define=rootfs=cramfs --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_CRAMFS[= ].*$$/CONFIG_CRAMFS=y/' $(IDE_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(NFSSERVER_SED_CONF) $(LZMA_SED_CONF) $(flash_kernel_conf) > $(KERNEL_DIR)/.config
endif
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
if KERNEL26
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $@/vmlinuz
else
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
endif
	$(MAKE) driver targetprefix=$@
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	rm -f $@/lib/modules/$(KERNELVERSION)/source
	rm -f $@/lib/modules/$(KERNELVERSION)/modules.[^d]*
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-jffs2: bootstrap $(hostprefix)/bin/mkimage
	rm -rf $@
if KERNEL26
	m4 --define=rootfs=jffs2 --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_JFFS2_FS[= ].*$$/CONFIG_JFFS2_FS=y/' $(IDE_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(NFSSERVER_SED_CONF) $(LZMA_SED_CONF) $(flash_kernel_conf) > $(KERNEL_DIR)/.config
else
	m4 --define=rootfs=jffs2 --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_JFFS2_FS[= ].*$$/CONFIG_JFFS2_FS=y/' $(IDE_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(NFSSERVER_SED_CONF) $(LZMA_SED_CONF) $(flash_kernel_conf) > $(KERNEL_DIR)/.config
endif
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
if KERNEL26
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $@/vmlinuz
else
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
endif
	$(MAKE) driver targetprefix=$@
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	rm -f $@/lib/modules/$(KERNELVERSION)/source
	rm -f $@/lib/modules/$(KERNELVERSION)/modules.[^d]*
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-squashfs: bootstrap $(hostprefix)/bin/mkimage
	rm -rf $@
if ENABLE_LZMA
PART_TYPE="squashfs+lzma"
else
PART_TYPE=squashfs
endif
if KERNEL26
	m4 --define=rootfs=$(PART_TYPE) --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_SQUASHFS[= ].*$$/CONFIG_SQUASHFS=y/' $(IDE_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(NFSSERVER_SED_CONF) $(LZMA_SED_CONF) $(flash_kernel_conf) > $(KERNEL_DIR)/.config
else
	m4 --define=rootfs=$(PART_TYPE) --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_SQUASHFS[= ].*$$/CONFIG_SQUASHFS=y/' $(IDE_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(NFSSERVER_SED_CONF) $(LZMA_SED_CONF) $(flash_kernel_conf) > $(KERNEL_DIR)/.config
endif
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
if KERNEL26
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $@/vmlinuz
else
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
endif
	$(MAKE) driver targetprefix=$@
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	rm -f $@/lib/modules/$(KERNELVERSION)/source
	rm -f $@/lib/modules/$(KERNELVERSION)/modules.[^d]*
	@TUXBOX_CUSTOMIZE@
