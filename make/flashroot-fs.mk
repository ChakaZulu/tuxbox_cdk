$(flashprefix)/root-cramfs: bootstrap_gcc $(MKIMAGE)
	rm -rf $@
if KERNEL26
	m4 --define=rootfs=cramfs --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_CRAMFS[= ].*$$/CONFIG_CRAMFS=y/' $(IDE_SED_CONF) $(EXT2_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(REISERFS_SED_CONF) $(NFSSERVER_SED_CONF) $(FS_NFS_SED_CONF) $(VFAT_SED_CONF) $(FS_CIFS_SED_CONF) $(FS_SMBFS_SED_CONF) $(AUTOMOUNT_SED_CONF) $(OPENVPN_SED_CONF) $(flash_kernel_conf) > $(KERNEL_DIR)/.config
else
	m4 --define=rootfs=cramfs --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_CRAMFS[= ].*$$/CONFIG_CRAMFS=y/' $(IDE_SED_CONF) $(EXT2_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(REISERFS_SED_CONF) $(NFSSERVER_SED_CONF) $(FS_NFS_SED_CONF) $(VFAT_SED_CONF) $(FS_CIFS_SED_CONF) $(FS_SMBFS_SED_CONF) $(AUTOMOUNT_SED_CONF) $(OPENVPN_SED_CONF) Patches/linux-2.4.35.5-dbox2.config-flash > $(KERNEL_DIR)/.config
endif
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
	sed $(JFFS2_SED_CONF) $(JFFS2_NOLZMA_SED_CONF) $(SQUASHFS_NO_SED_CONF) \
		$(IDE_SED_CONF) \
		$(EXT2_SED_CONF) $(EXT3_SED_CONF) \
		$(XFS_SED_CONF) \
		$(REISERFS_SED_CONF) \
		$(NFSSERVER_SED_CONF) $(FS_NFS_SED_CONF) \
		$(VFAT_SED_CONF) \
		$(FS_CIFS_SED_CONF) \
		$(FS_SMBFS_SED_CONF) \
		$(AUTOMOUNT_SED_CONF) \
		$(OPENVPN_SED_CONF) \
		$(flash_kernel_conf) > $(KERNEL_DIR)/.config
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
	sed $(JFFS2_SED_CONF) $(JFFS2_LZMA_SED_CONF) $(SQUASHFS_NO_SED_CONF) \
		$(IDE_SED_CONF) \
		$(EXT2_SED_CONF) $(EXT3_SED_CONF) \
		$(XFS_SED_CONF) \
		$(REISERFS_SED_CONF) \
		$(NFSSERVER_SED_CONF) $(FS_NFS_SED_CONF) \
		$(VFAT_SED_CONF) \
		$(FS_CIFS_SED_CONF) \
		$(FS_SMBFS_SED_CONF) \
		$(AUTOMOUNT_SED_CONF) \
		$(OPENVPN_SED_CONF) \
		$(flash_kernel_conf) > $(KERNEL_DIR)/.config
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
	sed $(JFFS2_SED_CONF) $(JFFS2_LZMA_SED_CONF) $(SQUASHFS_NO_SED_CONF) \
		$(IDE_SED_CONF) \
		$(EXT2_SED_CONF) $(EXT3_SED_CONF) \
		$(XFS_SED_CONF) \
		$(REISERFS_SED_CONF) \
		$(NFSSERVER_SED_CONF) $(FS_NFS_SED_CONF) \
		$(VFAT_SED_CONF) \
		$(FS_CIFS_SED_CONF) \
		$(FS_SMBFS_SED_CONF) \
		$(AUTOMOUNT_SED_CONF) \
		$(OPENVPN_SED_CONF) \
		$(flash_kernel_conf) > $(KERNEL_DIR)/.config
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
	sed $(SQUASHFS_SED_CONF) $(SQUASHFS_LZMA_SED_CONF) $(JFFS2_SED_CONF) \
		$(IDE_SED_CONF) \
		$(EXT2_SED_CONF) $(EXT3_SED_CONF) \
		$(XFS_SED_CONF) \
		$(REISERFS_SED_CONF) \
		$(NFSSERVER_SED_CONF) $(FS_NFS_SED_CONF) \
		$(VFAT_SED_CONF) \
		$(FS_CIFS_SED_CONF) \
		$(FS_SMBFS_SED_CONF) \
		$(AUTOMOUNT_SED_CONF) \
		$(OPENVPN_SED_CONF) \
		$(flash_kernel_conf) > $(KERNEL_DIR)/.config
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
	sed $(SQUASHFS_SED_CONF) $(SQUASHFS_NOLZMA_SED_CONF) $(JFFS2_SED_CONF) \
		$(IDE_SED_CONF) \
		$(EXT2_SED_CONF) $(EXT3_SED_CONF) \
		$(XFS_SED_CONF) \
		$(REISERFS_SED_CONF) \
		$(NFSSERVER_SED_CONF) $(FS_NFS_SED_CONF) \
		$(VFAT_SED_CONF) \
		$(FS_CIFS_SED_CONF) \
		$(FS_SMBFS_SED_CONF) \
		$(AUTOMOUNT_SED_CONF) \
		$(OPENVPN_SED_CONF) \
		$(flash_kernel_conf) > $(KERNEL_DIR)/.config
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
