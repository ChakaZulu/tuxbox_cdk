$(flashprefix)/root-cramfs: bootstrap_gcc $(MKIMAGE)
	rm -rf $@
if KERNEL26
	m4 --define=rootfs=cramfs --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
else
	m4 --define=rootfs=cramfs --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
endif
	m4 -Dflash -Djffs2 -Dcramfs $(KERNEL_M4) $(kernel_conf) > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
if KERNEL26
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $@/vmlinuz
else
	$(hostprefix)/bin/mkimage \
		-n 'Linux-$(KERNELVERSION)' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
endif
	$(MAKE) driver targetprefix=$@
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	rm -f $@/lib/modules/$(KERNELVERSION)/source
	rm -f $@/lib/modules/$(KERNELVERSION)/modules.[^d]*
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-jffs2: bootstrap_gcc $(MKIMAGE)
	rm -rf $@
if KERNEL26
	m4 --define=rootfs=jffs2 Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
else
	m4 --define=rootfs=jffs2 Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
endif
	m4 -Dflash -Djffs2 $(KERNEL_M4) $(kernel_conf) > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
if KERNEL26
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $@/vmlinuz
else
	$(hostprefix)/bin/mkimage \
		-n 'Linux-$(KERNELVERSION)' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
endif
	$(MAKE) driver targetprefix=$@
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	rm -f $@/lib/modules/$(KERNELVERSION)/source
	rm -f $@/lib/modules/$(KERNELVERSION)/modules.[^d]*
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-jffs2_lzma: bootstrap_gcc $(MKIMAGE)
	rm -rf $@
if KERNEL26
	m4 --define=rootfs=jffs2 --define=jffs2lzma Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
else
	m4 --define=rootfs=jffs2 --define=jffs2lzma Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
endif
	m4 -Dflash -Djffs2 -Djffs2lzma $(KERNEL_M4) $(kernel_conf) > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
if KERNEL26
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $@/vmlinuz
else
	$(hostprefix)/bin/mkimage \
		-n 'Linux-$(KERNELVERSION)' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
endif
	$(MAKE) driver targetprefix=$@
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	rm -f $@/lib/modules/$(KERNELVERSION)/source
	rm -f $@/lib/modules/$(KERNELVERSION)/modules.[^d]*
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-jffs2_lzma_klzma: bootstrap_gcc lzma_host $(MKIMAGE)
	rm -rf $@
if KERNEL26
	m4 --define=rootfs=jffs2 --define=jffs2lzma Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
else
	m4 --define=rootfs=jffs2 --define=jffs2lzma Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
endif
	m4 -Dflash -Djffs2 -Djffs2lzma $(KERNEL_M4) $(kernel_conf) > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
	rm -f $(dir $(KERNEL_BUILD_FILENAME))vmlinux.lzma
if KERNEL26
	$(hostprefix)/bin/lzma_alone e $(dir $(KERNEL_BUILD_FILENAME))vmlinux.bin $(dir $(KERNEL_BUILD_FILENAME))vmlinux.lzma
else
	gunzip -c $(KERNEL_BUILD_FILENAME) > $(dir $(KERNEL_BUILD_FILENAME))vmlinux
	$(hostprefix)/bin/lzma_alone e $(dir $(KERNEL_BUILD_FILENAME))vmlinux $(dir $(KERNEL_BUILD_FILENAME))vmlinux.lzma
endif
	$(hostprefix)/bin/mkimage \
		-n 'Linux-$(KERNELVERSION)' -A ppc -O linux -T kernel -C lzma \
		-a 00000000 -e 00000000 -d $(dir $(KERNEL_BUILD_FILENAME))vmlinux.lzma $@/vmlinuz
	$(MAKE) driver targetprefix=$@
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	rm -f $@/lib/modules/$(KERNELVERSION)/source
	rm -f $@/lib/modules/$(KERNELVERSION)/modules.[^d]*
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-squashfs: bootstrap_gcc $(MKIMAGE)
	rm -rf $@
if BOXTYPE_DREAMBOX
	sed $(AUTOMOUNT_SED_CONF) $(DREAMBOX_SERIAL_SED) \
		$(KERNEL_DIR)/arch/ppc/configs/$(BOXMODEL)_defconfig > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
else
if KERNEL26
	m4 --define=rootfs="squashfs+lzma" --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
else
	m4 --define=rootfs="squashfs+lzma" --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
endif
	m4 -Dflash -Djffs2 -Dsquashfs -Dsquashfslzma $(KERNEL_M4) $(kernel_conf) > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
if KERNEL26
	$(INSTALL) -m644 $(KERNEL_BUILD_FILENAME) $@/vmlinuz
else
	$(hostprefix)/bin/mkimage \
		-n 'Linux-$(KERNELVERSION)' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
endif
	$(MAKE) driver targetprefix=$@
endif
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	rm -f $@/lib/modules/$(KERNELVERSION)/source
	rm -f $@/lib/modules/$(KERNELVERSION)/modules.[^d]*
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-squashfs_nolzma: bootstrap_gcc $(MKIMAGE)
	rm -rf $@
if BOXTYPE_DREAMBOX
	sed $(AUTOMOUNT_SED_CONF) $(DREAMBOX_SERIAL_SED) \
		$(KERNEL_DIR)/arch/ppc/configs/$(BOXMODEL)_defconfig > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
else
if KERNEL26
	m4 --define=rootfs=squashfs --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
else
	m4 --define=rootfs=squashfs --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
endif
	m4 -Dflash -Djffs2 -Dsquashfs $(KERNEL_M4) $(kernel_conf) > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
if KERNEL26
	$(INSTALL) -m644 $(KERNEL_BUILD_FILENAME) $@/vmlinuz
else
	$(hostprefix)/bin/mkimage \
		-n 'Linux-$(KERNELVERSION)' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
endif
	$(MAKE) driver targetprefix=$@
endif
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	rm -f $@/lib/modules/$(KERNELVERSION)/source
	rm -f $@/lib/modules/$(KERNELVERSION)/modules.[^d]*
	@TUXBOX_CUSTOMIZE@
