#######################
#
#   ide apps
#


ide_apps: hdparm utillinux e2fsprogs parted hddtemp xfsprogs smartmontools @DOSFSTOOLS@

IDE_DEPSCLEANUP = rm -f .deps/hdparm .deps/e2fsprogs .deps/utillinux .deps/parted .deps/hddtemp .deps/xfsprogs .deps/smartmontools

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
XFSPROGSOPT=ac_cv_header_aio_h=yes ac_cv_lib_rt_lio_listio=yes
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
		ln -sf /proc/mounts $(targetprefix)/etc/mtab && \
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
		ln -sf /proc/mounts $(flashprefix)/root/etc/mtab && \
		@INSTALL_e2fsprogs@
if !BOXTYPE_DREAMBOX
	$(INSTALL) $(targetprefix)/sbin/badblocks $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/resize2fs $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/tune2fs $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/fsck $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/e2label $(flashprefix)/root/sbin/
endif
	$(INSTALL) $(targetprefix)/sbin/e2fsck $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/mke2fs $(flashprefix)/root/sbin/
if ENABLE_EXT2
	@ln -sf mke2fs $(flashprefix)/root/sbin/mkfs.ext2
	@ln -sf e2fsck $(flashprefix)/root/sbin/fsck.ext2
endif
if ENABLE_EXT3
	@ln -sf mke2fs $(flashprefix)/root/sbin/mkfs.ext3
	@ln -sf e2fsck $(flashprefix)/root/sbin/fsck.ext3
endif
		@CLEANUP_e2fsprogs@
	@FLASHROOTDIR_MODIFIED@
endif

#parted
$(DEPDIR)/parted: bootstrap libreadline libncurses e2fsprogs @DEPENDS_parted@
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
		$(INSTALL) -d $(targetprefix)/share/tuxbox
		$(INSTALL) -m 644 config/hddtemp.db $(targetprefix)/share/tuxbox
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
		$(INSTALL) -d $(flashprefix)/root/share/tuxbox
		$(INSTALL) -m 644 config/hddtemp.db $(flashprefix)/root/share/tuxbox
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
		$(XFSPROGSOPT) \
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
		$(XFSPROGSOPT) \
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

#reiserfsprogs
# reiserfsprogs needs "special" built libtool and uuid header/lib of e2fsprogs
$(DEPDIR)/reiserfsprogs: bootstrap libtool @DEPENDS_e2fsprogs@ @DEPENDS_reiserfsprogs@
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
	@CLEANUP_e2fsprogs@
	@PREPARE_reiserfsprogs@
	cd @DIR_reiserfsprogs@ && \
		LIBTOOL=$(hostprefix)/bin/libtool \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--includedir=$(targetprefix)/include \
			--prefix= && \
		$(MAKE) && \
		@INSTALL_reiserfsprogs@
		@ln -sf mkreiserfs $(targetprefix)/sbin/mkfs.reiserfs
		@ln -sf reiserfsck $(targetprefix)/sbin/fsck.reiserfs
	@CLEANUP_reiserfsprogs@
	touch $@

if TARGETRULESET_FLASH

flash-reiserfsprogs: $(flashprefix)/root/sbin/mkreiserfs $(flashprefix)/root/sbin/reiserfsck

$(flashprefix)/root/sbin/mkreiserfs: bootstrap libtool reiserfsprogs | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/sbin/mkreiserfs $(flashprefix)/root/sbin
	@ln -sf mkreiserfs $(flashprefix)/root/sbin/mkfs.reiserfs
	@FLASHROOTDIR_MODIFIED@

$(flashprefix)/root/sbin/reiserfsck: bootstrap libtool reiserfsprogs | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/sbin/reiserfsck $(flashprefix)/root/sbin
	@ln -sf reiserfsck $(flashprefix)/root/sbin/fsck.reiserfs
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

$(DEPDIR)/dosfstools: bootstrap @DEPENDS_dosfstools@
	@PREPARE_dosfstools@
	cd @DIR_dosfstools@ && \
		$(MAKE) all \
		CC=$(target)-gcc \
		OPTFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer -D_FILE_OFFSET_BITS=64" && \
		@INSTALL_dosfstools@		
		@CLEANUP_dosfstools@
	touch $@

if TARGETRULESET_FLASH

flash-dosfstools: $(flashprefix)/root/sbin/mkfs.msdos

$(flashprefix)/root/sbin/mkfs.msdos: dosfstools | $(flashprefix)/root
	@$(INSTALL) -d $(flashprefix)/root/sbin
	@for i in mkdosfs dosfsck; do \
	$(INSTALL) $(targetprefix)/sbin/$$i $(flashprefix)/root/sbin; done;
		@ln -sf mkdosfs $@
		@ln -sf mkdosfs $(flashprefix)/root/sbin/mkfs.vfat
		@ln -sf dosfsck $(flashprefix)/root/sbin/fsck.msdos
		@ln -sf dosfsck $(flashprefix)/root/sbin/fsck.vfat
	@FLASHROOTDIR_MODIFIED@

endif
