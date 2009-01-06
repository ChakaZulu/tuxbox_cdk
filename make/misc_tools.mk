# misc/tools

$(appsdir)/misc/tools/config.status: bootstrap libpng
	cd $(appsdir)/misc/tools && $(CONFIGURE)

misc_tools: $(appsdir)/misc/tools/config.status
	$(MAKE) -C $(appsdir)/misc/tools all install


if TARGETRULESET_FLASH
flash-misc_tools: $(appsdir)/misc/tools/config.status
	$(MAKE) -C $(appsdir)/misc/tools all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-eraseall: $(flashprefix)/root/sbin/eraseall

$(flashprefix)/root/sbin/eraseall: misc_tools | $(flashprefix)/root
	$(INSTALL) $(appsdir)/misc/tools/mtd/eraseall $@
	@FLASHROOTDIR_MODIFIED@

flash-fcp: $(flashprefix)/root/sbin/fcp

$(flashprefix)/root/sbin/fcp: misc_tools | $(flashprefix)/root
	$(INSTALL) $(appsdir)/misc/tools/mtd/fcp $@
	@FLASHROOTDIR_MODIFIED@

flash-dboxshot: $(flashprefix)/root/bin/dboxshot

$(flashprefix)/root/bin/dboxshot: $(appsdir)/misc/tools/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/misc/tools/dboxshot all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-fbshot: $(flashprefix)/root/bin/fbshot

$(flashprefix)/root/bin/fbshot: $(appsdir)/misc/tools/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/misc/tools/fbshot all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-etherwake: $(flashprefix)/root/bin/etherwake

$(flashprefix)/root/bin/etherwake: $(appsdir)/misc/tools/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/misc/tools/etherwake all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-rtc: $(flashprefix)/root/bin/hwrtc

$(flashprefix)/root/bin/hwrtc:  $(appsdir)/misc/tools/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/misc/tools/rtc all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-makedevices: $(flashprefix)/root/bin/makedevices

$(flashprefix)/root/bin/makedevices:  $(appsdir)/misc/tools/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/misc/tools/makedevices all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

endif
