if ENABLE_DOSFSTOOLS

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

endif
