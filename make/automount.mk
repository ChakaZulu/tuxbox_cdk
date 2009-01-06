# Note: for the automounter, the kernel has to have the configuration
# option CONFIG_AUTOFS4_FS enabled. At this time, this must be changed
# manually.

$(DEPDIR)/automount: bootstrap @DEPENDS_automount@ Patches/autofs.diff
	@PREPARE_automount@
	cd @DIR_automount@  && \
		$(BUILDENV) STRIP=$(target)-strip \
		$(MAKE) && \
		$(MAKE) install INSTALLROOT=$(targetprefix)
	rm -rf @DIR_automount@
#	$(INSTALL) $(buildprefix)/root/etc/init.d/start_automount $(targetprefix)/etc/init.d
	$(INSTALL) $(buildprefix)/root/etc/auto.net $(targetprefix)/etc
	ln -sf /proc/mounts $(targetprefix)/etc/mtab
	@touch $@

if TARGETRULESET_FLASH

flash-automount: @DEPENDS_automount@ Patches/autofs.diff | $(flashprefix)/root
	@PREPARE_automount@
	cd @DIR_automount@  && \
		$(BUILDENV) STRIP=$(target)-strip \
		$(MAKE) && \
		$(MAKE) install SUBDIRS="lib daemon modules" INSTALLROOT=$(flashprefix)/root
	rm -rf @DIR_automount@
#	$(INSTALL) $(buildprefix)/root/etc/init.d/start_automount $(flashprefix)/root/etc/init.d
	ln -sf /proc/mounts $(flashprefix)/root/etc/mtab
	rm -f $(flashprefix)/root/lib/autofs/lookup_multi.so
	rm -f $(flashprefix)/root/lib/autofs/lookup_program.so
	rm -f $(flashprefix)/root/lib/autofs/lookup_userhome.so
	rm -f $(flashprefix)/root/lib/autofs/lookup_yp.so
	rm -f $(flashprefix)/root/lib/autofs/mount_afs.so
	rm -f $(flashprefix)/root/lib/autofs/mount_autofs.so
	rm -f $(flashprefix)/root/lib/autofs/mount_changer.so
	@FLASHROOTDIR_MODIFIED@
endif

.PHONY: flash-automount
