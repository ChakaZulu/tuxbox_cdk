#######################
#
#   ide apps
#


ide_apps: hdparm utillinux e2fsprogs parted hddtemp xfsprogs smartmontools

IDE_DEPSCLEANUP = rm -f .deps/hdparm .deps/e2fsprogs .deps/utillinux .deps/parted .deps/hddtemp .deps/xfsprogs .deps/smartmontools

if ENABLE_IDE
#hdparm
$(DEPDIR)/hdparm: bootstrap @DEPENDS_hdparm@
	@PREPARE_hdparm@
	cd @DIR_hdparm@ && \
		$(BUILDENV) \
		$(MAKE) CROSS=$(target)- all && \
		@INSTALL_hdparm@
		@CLEANUP_hdparm@
	touch $@

if TARGETRULESET_FLASH
flash-hdparm: $(flashprefix)/root/sbin/hdparm

$(flashprefix)/root/sbin/hdparm: bootstrap @DEPENDS_hdparm@ | $(flashprefix)/root
	@PREPARE_hdparm@
	cd @DIR_hdparm@ && \
		$(BUILDENV) \
		$(MAKE) CROSS=$(target)- all && \
		$(MAKE) install DESTDIR=$(targetprefix)
		$(INSTALL) $(targetprefix)/sbin/hdparm $(flashprefix)/root/sbin/
	@CLEANUP_hdparm@
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@

endif


# contains [cs]fdisk etc
$(DEPDIR)/utillinux: bootstrap @DEPENDS_utillinux@
	@PREPARE_utillinux@
	cd @DIR_utillinux@ && \
		CC=$(target)-gcc \
		CFLAGS="-Os -msoft-float -I$(targetprefix)/include/ncurses" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure && \
		$(MAKE) ARCH=ppc all && \
		@INSTALL_utillinux@
	@CLEANUP_utillinux@
	touch $@

if TARGETRULESET_FLASH
flash-sfdisk: $(flashprefix)/root/sbin/sfdisk

$(flashprefix)/root/sbin/sfdisk: utillinux
	$(INSTALL) $(targetprefix)/sbin/sfdisk $@
	@FLASHROOTDIR_MODIFIED@

flash-cfdisk: $(flashprefix)/root/sbin/cfdisk

$(flashprefix)/root/sbin/cfdisk: utillinux
	$(INSTALL) $(targetprefix)/sbin/cfdisk $@
	@FLASHROOTDIR_MODIFIED@

#replaces busybox fdisk
flash-fdisk: $(flashprefix)/root/sbin/fdisk

$(flashprefix)/root/sbin/fdisk: utillinux
	$(INSTALL) $(targetprefix)/sbin/fdisk $@
	@FLASHROOTDIR_MODIFIED@

endif

if TARGETRULESET_UCLIBC
E2FSPROGSOPT=--disable-tls
endif

#e2fs2progs
$(DEPDIR)/e2fsprogs: bootstrap @DEPENDS_e2fsprogs@
	@PREPARE_e2fsprogs@
	cd @DIR_e2fsprogs@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) \
			--with-cc=$(target)-gcc \
			--with-linker=$(target)-ld \
			--disable-evms \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-e2initrd-helper \
			--disable-swapfs \
			--disable-debugfs \
			--disable-image \
			--enable-resizer \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			$(E2FSPROGSOPT) \
			--disable-nls && \
		$(MAKE) libs progs && \
		$(MAKE) install-libs && \
		@INSTALL_e2fsprogs@
	@CLEANUP_e2fsprogs@
	touch $@

if TARGETRULESET_FLASH

flash-e2fsprogs: $(flashprefix)/root/sbin/e2fsck

$(flashprefix)/root/sbin/e2fsck: bootstrap @DEPENDS_e2fsprogs@ | $(flashprefix)/root
	@PREPARE_e2fsprogs@
	cd @DIR_e2fsprogs@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) \
			--with-cc=$(target)-gcc \
			--with-linker=$(target)-ld \
			--disable-evms \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-e2initrd-helper \
			--disable-swapfs \
			--disable-debugfs \
			--disable-image \
			--enable-resizer \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			$(E2FSPROGSOPT) \
			--disable-nls && \
		$(MAKE) libs progs && \
		$(MAKE) install-libs && \
		@INSTALL_e2fsprogs@
	$(INSTALL) $(targetprefix)/sbin/badblocks $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/resize2fs $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/tune2fs $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/fsck $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/fsck.ext2 $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/mkfs.ext2 $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/e2label $(flashprefix)/root/sbin/
if ENABLE_EXT3
	$(INSTALL) $(targetprefix)/sbin/fsck.ext3 $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/mkfs.ext3 $(flashprefix)/root/sbin/
endif
		@CLEANUP_e2fsprogs@
	@@FLASHROOTDIR_MODIFIED@@
endif

#parted
$(DEPDIR)/parted: bootstrap libreadline e2fsprogs @DEPENDS_parted@
	@PREPARE_parted@
	cd @DIR_parted@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		$(MAKE) all && \
		@INSTALL_parted@
	@CLEANUP_parted@
	touch $@

#hddtemp
$(DEPDIR)/hddtemp: bootstrap @DEPENDS_hddtemp@
	@PREPARE_hddtemp@
	cd @DIR_hddtemp@ && \
		$(BUILDENV) \
		./configure \
		--with-db-path=/share/tuxbox/hddtemp.db \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		$(MAKE) install DESTDIR=$(targetprefix)
		$(INSTALL) -m 644 Patches/hddtemp.db $(targetprefix)/share/tuxbox
	@CLEANUP_hddtemp@
	touch $@ 

if TARGETRULESET_FLASH
flash-hddtemp: $(flashprefix)/root/sbin/hddtemp

$(flashprefix)/root/sbin/hddtemp: bootstrap @DEPENDS_hddtemp@ | $(flashprefix)/root
	@PREPARE_hddtemp@
	cd @DIR_hddtemp@ && \
		$(BUILDENV) \
		./configure \
		--with-db-path=/share/tuxbox/hddtemp.db \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		$(MAKE) install DESTDIR=$(flashprefix)/root
		$(INSTALL) -m 644 Patches/hddtemp.db $(flashprefix)/root/share/tuxbox
	@CLEANUP_hddtemp@
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@

endif

#xfsprogs
# xfsprogs needs "special" built libtool and uuid header/lib of e2fsprogs
$(DEPDIR)/xfsprogs: bootstrap libtool @DEPENDS_e2fsprogs@ @DEPENDS_xfsprogs@
	@PREPARE_e2fsprogs@
	cd @DIR_e2fsprogs@ && \
		RANLIB=$(target)-ranlib \
		CC=$(target)-gcc \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix= \
			--with-cc=$(target)-gcc \
			--with-linker=$(target)-ld \
			--disable-evms \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-swapfs \
			--disable-debugfs \
			--disable-image \
			--enable-resizer \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			$(E2FSPROGSOPT) \
			--disable-nls && \
		$(MAKE) libs && \
		$(INSTALL) -d $(targetprefix)/include/uuid && \
		$(INSTALL) -m 644 lib/uuid/uuid.h $(targetprefix)/include/uuid && \
		$(INSTALL) -m 644 lib/uuid/uuid_types.h $(targetprefix)/include/uuid && \
		$(INSTALL) lib/uuid/libuuid.a $(targetprefix)/lib && \
		$(INSTALL) lib/uuid/libuuid.so.1.2 $(targetprefix)/lib && \
		ln -sf libuuid.so.1.2 $(targetprefix)/lib/libuuid.so.1 && \
		ln -sf libuuid.so.1 $(targetprefix)/lib/libuuid.so
#		$(MAKE) libs
#		$(MAKE) install-libs DESTDIR=$(targetprefix)
	@CLEANUP_e2fsprogs@
	@PREPARE_xfsprogs@
	cd @DIR_xfsprogs@ && \
		LIBTOOL=$(hostprefix)/bin/libtool \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--includedir=$(targetprefix)/include \
			--prefix=$(targetprefix) &&\
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(targetprefix)
	@CLEANUP_xfsprogs@
	touch $@

if TARGETRULESET_FLASH
flash-xfsprogs: $(flashprefix)/root/sbin/mkfs.xfs

$(flashprefix)/root/sbin/mkfs.xfs: bootstrap libtool @DEPENDS_e2fsprogs@ @DEPENDS_xfsprogs@ | $(flashprefix)/root
	@PREPARE_e2fsprogs@
	cd @DIR_e2fsprogs@ && \
		RANLIB=$(target)-ranlib \
		CC=$(target)-gcc \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix= \
			--with-cc=$(target)-gcc \
			--with-linker=$(target)-ld \
			--disable-evms \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-swapfs \
			--disable-debugfs \
			--disable-image \
			--enable-resizer \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			$(E2FSPROGSOPT) \
			--disable-nls && \
		$(MAKE) libs && \
		$(INSTALL) -d $(targetprefix)/include/uuid && \
		$(INSTALL) -m 644 lib/uuid/uuid.h $(targetprefix)/include/uuid && \
		$(INSTALL) -m 644 lib/uuid/uuid_types.h $(targetprefix)/include/uuid && \
		$(INSTALL) lib/uuid/libuuid.a $(targetprefix)/lib && \
		$(INSTALL) lib/uuid/libuuid.so.1.2 $(targetprefix)/lib && \
		ln -sf libuuid.so.1.2 $(targetprefix)/lib/libuuid.so.1 && \
		ln -sf libuuid.so.1 $(targetprefix)/lib/libuuid.so
#		$(MAKE) libs
#		$(MAKE) install-libs DESTDIR=$(targetprefix)
	@CLEANUP_e2fsprogs@
	@PREPARE_xfsprogs@
	cd @DIR_xfsprogs@ && \
		LIBTOOL=$(hostprefix)/bin/libtool \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--includedir=$(targetprefix)/include \
			--prefix=$(targetprefix) && \
		$(MAKE) && \
		for i in mkfs/mkfs.xfs repair/xfs_repair; do \
			$(INSTALL) $$i $(flashprefix)/root/sbin; done;
	@CLEANUP_xfsprogs@
	@FLASHROOTDIR_MODIFIED@

endif

#smartmontools
$(DEPDIR)/smartmontools: bootstrap @DEPENDS_smartmontools@
	@PREPARE_smartmontools@
	cd @DIR_smartmontools@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--includedir=$(targetprefix)/include \
			--prefix=$(targetprefix) &&\
		$(MAKE) && \
		$(MAKE) install DESTDIR=
	@CLEANUP_smartmontools@
	touch $@

if TARGETRULESET_FLASH
flash-smartmontools: $(flashprefix)/root/sbin/smartctl

$(flashprefix)/root/sbin/smartctl: bootstrap @DEPENDS_smartmontools@ | $(flashprefix)/root
	@PREPARE_smartmontools@
	cd @DIR_smartmontools@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--includedir=$(targetprefix)/include \
			--prefix=$(targetprefix) &&\
		$(MAKE) && \
		for i in smartctl ; do \
			$(INSTALL) $$i $(flashprefix)/root/sbin; done;
	@CLEANUP_smartmontools@
	@FLASHROOTDIR_MODIFIED@

endif
endif


