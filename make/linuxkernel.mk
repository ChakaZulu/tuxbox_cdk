# Kernel
#
# Yes, this depends on $(KERNEL_DIR)/.config, which the Makefile does not have
# as a target.
# This is deliberate, and makes the target "private".

$(KERNEL_BUILD_FILENAME): bootstrap linuxdir install-linux-headers $(KERNEL_DIR)/.config
if BOXTYPE_DREAMBOX
	$(MAKE) -C $(KERNEL_DIR) zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
else
	$(MAKE) -C $(KERNEL_DIR) oldconfig ARCH=ppc
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) include/asm \
		ARCH=ppc
endif
	$(MAKE) -C $(KERNEL_DIR) include/linux/version.h ARCH=ppc
if BOXTYPE_IPBOX
	$(MAKE) -C $(KERNEL_DIR) vmlinux modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
else
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) uImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		INSTALL_MOD_PATH=$(targetprefix)
else
	$(MAKE) -C $(KERNEL_DIR) zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
endif
endif
endif
# if KERNEL26
# 	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $(bootprefix)/kernel-cdk
# else
#	$(hostprefix)/bin/mkimage \
#		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
#		-a 00000000 -e 00000000 \
#		-d $(KERNEL_DIR)/arch/ppc/boot/images/vmlinux.gz \
#		$(bootprefix)/kernel-cdk
# endif
#	$(INSTALL) -m644 $(KERNEL_DIR)/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
#	$(INSTALL) -m644 $(KERNEL_DIR)/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)
#	touch $@

if BOXTYPE_DREAMBOX
$(DEPDIR)/install-linux-headers: linuxdir @DEPENDS_linux_dream_kernel_headers@
else
if BOXTYPE_IPBOX
$(DEPDIR)/install-linux-headers: linuxdir @DEPENDS_linux_ipbox_kernel_headers@
else
$(DEPDIR)/install-linux-headers: linuxdir
endif
endif
if BOXTYPE_DREAMBOX
	@PREPARE_linux_dream_kernel_headers@
	mv $(buildprefix)/@DIR_linux_dream_kernel_headers@/include/asm-ppc $(buildprefix)/@DIR_linux_dream_kernel_headers@/include/asm
	for i in linux asm asm_generic; do \
		rm -R $(hostprefix)/$(target)/include/$$i 2> /dev/null || /bin/true; \
		if [ $$i != asm_generic ] ; then \
			mv $(buildprefix)/@DIR_linux_dream_kernel_headers@/include/$$i $(hostprefix)/$(target)/include; \
		fi; \
	done;
	for i in config.h autoconf.h; do \
		ln -sf $(buildprefix)/linux/include/linux/$$i $(hostprefix)/$(target)/include/linux; \
	done;
	@CLEANUP_linux_dream_kernel_headers@
else
if BOXTYPE_IPBOX
	@PREPARE_linux_ipbox_kernel_headers@
	mv $(buildprefix)/@DIR_linux_ipbox_kernel_headers@/include/asm-powerpc $(buildprefix)/@DIR_linux_ipbox_kernel_headers@/include/asm
	for i in linux asm asm-generic mtd scsi; do \
		rm -R $(hostprefix)/$(target)/include/$$i 2> /dev/null || /bin/true; \
		mv $(buildprefix)/@DIR_linux_ipbox_kernel_headers@/include/$$i $(hostprefix)/$(target)/include; \
	done;
	for i in config.h autoconf.h; do \
		ln -sf $(buildprefix)/linux/include/linux/$$i $(hostprefix)/$(target)/include/linux; \
	done;
	echo "/* empty */" > $(hostprefix)/$(target)/include/linux/compiler.h
	@CLEANUP_linux_ipbox_kernel_headers@
else
if KERNEL26
# Kernels after 2.6.18 offer a special "headers_install" target to generate
# "userspace-blessed" heades. This will create an include directory in
# $(KERNEL_DIR)/usr

# It would be more correct to copy all directories, but some files seem to also
# be provided by the glibc (e.g. scsi) so the directory exists and we simply use
# those directories that are necessary. This is a rule of its own since glibc
# needs the linux headers to build. For 2.4 this does nothing. Note that we cheat
# here and declare the target powerpc since ppc will be gone in a not too distant
# future and the headers are slowly being removed.
	@if [ `echo $(KERNELVERSION) | sed -e 's/\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\).*/\3/g'` -lt 18 ]; then \
		ln -sf $(buildprefix)/linux/include/linux $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/include/asm $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/include/asm-generic $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/include/mtd $(hostprefix)/$(target)/include; \
	else \
		$(MAKE) -C $(KERNEL_DIR) headers_install ARCH=powerpc; \
		ln -sf $(buildprefix)/linux/usr/include/linux $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/usr/include/asm $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/usr/include/asm-generic $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/usr/include/mtd $(hostprefix)/$(target)/include; \
	fi
endif
endif
endif
	touch $@


if ENABLE_LZMA
LZMA_SED_CONF=$(foreach param,CONFIG_SQUASHFS_LZMA,-e s"/^.*$(param)[= ].*/$(param)=y/")
else
LZMA_SED_CONF=$(foreach param,CONFIG_SQUASHFS_LZMA,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
endif

if ENABLE_IDE
IDE_SED_CONF=$(foreach param,CONFIG_IDE CONFIG_BLK_DEV_IDE CONFIG_BLK_DEV_IDEDISK,-e s"/^.*$(param)[= ].*/$(param)=m/")
else
if KERNEL26
IDE_SED_CONF=$(foreach param,CONFIG_IDE CONFIG_BLK_DEV_IDE CONFIG_BLK_DEV_IDEDISK CONFIG_MSDOS_PARTITION,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
else
IDE_SED_CONF=$(foreach param,CONFIG_MSDOS_PARTITION,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
endif
endif

if ENABLE_EXT2
EXT2_SED_CONF=$(foreach param,CONFIG_EXT2_FS CONFIG_JBD,-e s"/^.*$(param)[= ].*/$(param)=m/")
else
if KERNEL26
EXT2_SED_CONF=$(foreach param,CONFIG_EXT2_FS CONFIG_JBD,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
else
EXT2_SED_CONF=-e ""
endif
endif

if ENABLE_EXT3
EXT3_SED_CONF=$(foreach param,CONFIG_EXT3_FS CONFIG_JBD,-e s"/^.*$(param)[= ].*/$(param)=m/")
else
if KERNEL26
EXT3_SED_CONF=$(foreach param,CONFIG_EXT3_FS CONFIG_JBD,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
else
EXT3_SED_CONF=-e ""
endif
endif

if ENABLE_XFS
XFS_SED_CONF=$(foreach param,CONFIG_XFS_FS,-e s"/^.*$(param)[= ].*/$(param)=m/")
XFS_UCLIBC_CONF=$(foreach param,UCLIBC_HAS_OBSOLETE_BSD_SIGNAL UCLIBC_SV4_DEPRECATED,-e s"/^.*$(param)[= ].*/$(param)=y/")
else
XFS_UCLIBC_CONF=-e ""
if KERNEL26
XFS_SED_CONF=$(foreach param,CONFIG_XFS_FS,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
else
XFS_SED_CONF=-e ""
endif
endif

if ENABLE_VFAT
VFAT_SED_CONF=$(foreach param,CONFIG_FAT_FS CONFIG_VFAT_FS,-e s"/^.*$(param)[= ].*/$(param)=m/")
else
if KERNEL26
VFAT_SED_CONF=$(foreach param,CONFIG_FAT_FS CONFIG_MSDOS_FS CONFIG_VFAT_FS,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
else
VFAT_SED_CONF=-e ""
endif
endif

if ENABLE_FS_CIFS
FS_CIFS_SED_CONF=-e ""
else
FS_CIFS_SED_CONF=$(foreach param,CONFIG_CIFS CONFIG_CIFS_POSIX,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
endif

if ENABLE_FS_SMBFS
FS_SMBFS_SED_CONF=$(foreach param,CONFIG_SMB_FS CONFIG_NLS,-e s"/^.*$(param)[= ].*/$(param)=m/")
else
FS_SMBFS_SED_CONF=$(foreach param,CONFIG_SMB_FS CONFIG_SMB_UNIX CONFIG_NLS,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
endif

if ENABLE_AUTOMOUNT
if BOXTYPE_DREAMBOX
# this replaces cdk/Patches/linux-enable-autofs.diff from the dreambox branch
AUTOMOUNT_SED_CONF=$(foreach param,CONFIG_AUTOFS4_FS,-e s"/^.*$(param)[= ].*/\$(param)=m/")
else
AUTOMOUNT_SED_CONF=-e ""
endif
else
AUTOMOUNT_SED_CONF=$(foreach param,CONFIG_AUTOFS4_FS,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
endif

if ENABLE_NFSSERVER
if KERNEL26
NFSSERVER_SED_CONF=$(foreach param,CONFIG_NFSD CONFIG_EXPORTFS,-e s"/^.*$(param)[= ].*/$(param)=m/")
NFSSERVER_SED_CONF+=$(foreach param,CONFIG_NFSD_V3 CONFIG_NFSD_TCP,-e s"/^.*$(param)[= ].*/$(param)=y/")
else
NFSSERVER_SED_CONF=$(foreach param,CONFIG_NFSD CONFIG_NFSD_V3 CONFIG_NFSD_TCP,-e s"/^.*$(param)[= ].*/$(param)=m/")
endif
else
if KERNEL26
NFSSERVER_SED_CONF=$(foreach param,CONFIG_NFSD CONFIG_NFSD_V3 CONFIG_NFSD_TCP,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
else
NFSSERVER_SED_CONF=-e ""
endif
endif

# this option is ignored for target kernel-cdk, yadd needs NFS
if !ENABLE_FS_NFS
FS_NFS_SED_CONF=$(foreach param,CONFIG_NFS_FS CONFIG_NFS_V3 CONFIG_SUNRPC CONFIG_LOCKD CONFIG_LOCKD_V4 CONFIG_ROOT_NFS CONFIG_NFS_COMMON,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
endif

if DREAMBOX_ENABLE_SERIAL_CONSOLE
DREAMBOX_SERIAL_SED=-e "s/console=null/console=ttyS0,115200/"
else
DREAMBOX_SERIAL_SED=-e ""
endif

kernel-cdk: $(bootprefix)/kernel-cdk

if BOXTYPE_DBOX2
if KERNEL26
$(bootprefix)/kernel-cdk: linuxdir $(hostprefix)/bin/mkimage $(yadd_kernel_conf) Patches/dbox2-flash.c-26.m4
	sed $(IDE_SED_CONF) $(EXT2_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(VFAT_SED_CONF) $(NFSSERVER_SED_CONF) $(FS_CIFS_SED_CONF) $(FS_SMBFS_SED_CONF) $(AUTOMOUNT_SED_CONF) $(yadd_kernel_conf) \
		> $(KERNEL_DIR)/.config
	m4 --define=rootfs=$(FLASH_FS_TYPE) --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
else
$(bootprefix)/kernel-cdk: linuxdir $(hostprefix)/bin/mkimage $(yadd_kernel_conf) Patches/dbox2-flash.c.m4
	sed $(IDE_SED_CONF) $(EXT2_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(VFAT_SED_CONF) $(NFSSERVER_SED_CONF) $(FS_CIFS_SED_CONF) $(FS_SMBFS_SED_CONF) $(AUTOMOUNT_SED_CONF) $(yadd_kernel_conf) \
		> $(KERNEL_DIR)/.config
	m4 --define=rootfs=$(FLASH_FS_TYPE) --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
endif
	$(MAKE) $(KERNEL_BUILD_FILENAME)
if KERNEL26
# not tested
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $@
else
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 \
		-d $(KERNEL_BUILD_FILENAME) \
		$@
endif
	chmod 644 $@
	$(INSTALL) -m644 $(KERNEL_DIR)/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
	$(INSTALL) -m644 $(KERNEL_DIR)/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)
	$(INSTALL) -d $(targetprefix)/tmp
	$(INSTALL) -d $(targetprefix)/proc
	$(INSTALL) -d $(targetprefix)/var/run
endif

if ENABLE_MMC
DRIVER_MMC=yes
endif

driver: $(KERNEL_BUILD_FILENAME)
	$(MAKE) -C $(driverdir) \
		DRIVER_MMC=$(DRIVER_MMC) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(driverdir) \
		DRIVER_MMC=$(DRIVER_MMC) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)- \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix) \
		install

driver-clean:
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		distclean
#	-rm $(DEPDIR)/driver

$(driverdir)/directfb/Makefile: bootstrap libdirectfb
	cd $(driverdir)/directfb && \
	$(BUILDENV) \
	./autogen.sh \
		--build=$(build) \
		--host=$(target) \
		--prefix= \
		--enable-maintainer-mode \
		--with-kernel-source=$(buildprefix)/linux

$(DEPDIR)/directfb_gtx: $(driverdir)/directfb/Makefile
	$(MAKE) -C $(driverdir)/directfb all install DESTDIR=$(targetprefix)
	touch $@

.PHONY: driver-clean
