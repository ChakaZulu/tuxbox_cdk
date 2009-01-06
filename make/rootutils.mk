root_optional: mrouted

$(DEPDIR)/module_init_tools: bootstrap       @DEPENDS_module_init_tools@
	@PREPARE_module_init_tools@
	cd @DIR_module_init_tools@ && \
		$(BUILDENV) \
		./configure \
		      --build=$(build) \
		      --host=$(target) \
		      --prefix= && \
		$(MAKE) && \
		@INSTALL_module_init_tools@
	@CLEANUP_module_init_tools@
	touch $@

if TARGETRULESET_FLASH
flash-module-init-tools: $(flashprefix)/root/sbin/modprobe
$(flashprefix)/root/sbin/modprobe: module_init_tools
	$(INSTALL) $(targetprefix)/sbin/insmod $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/modprobe $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/depmod $(flashprefix)/root/sbin
	@FLASHROOTDIR_MODIFIED@
endif

$(DEPDIR)/modutils: bootstrap @DEPENDS_modutils@
	@PREPARE_modutils@
	cd @DIR_modutils@ && \
		$(BUILDENV) \
		BUILDCC=$(CC) BUILDCFLAGS="-O2" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-root-check \
			--disable-strip && \
		$(MAKE) && \
		@INSTALL_modutils@
	@CLEANUP_modutils@
	touch $@

$(DEPDIR)/portmap: bootstrap @DEPENDS_portmap@
	@PREPARE_portmap@
	cd @DIR_portmap@ && \
		$(BUILDENV) \
		$(MAKE) && \
		@INSTALL_portmap@
	@CLEANUP_portmap@
	touch $@

if TARGETRULESET_FLASH
flash-portmap: $(flashprefix)/root/sbin/portmap

$(flashprefix)/root/sbin/portmap: bootstrap @DEPENDS_portmap@ | $(flashprefix)/root
	@PREPARE_portmap@
	cd @DIR_portmap@ && \
		$(BUILDENV) \
		$(MAKE) && \
		$(INSTALL) -m 755 portmap $(flashprefix)/root/sbin
	@CLEANUP_portmap@
	@FLASHROOTDIR_MODIFIED@
endif

$(DEPDIR)/procps: bootstrap libncurses @DEPENDS_procps@
	@PREPARE_procps@
	cd @DIR_procps@ && \
		$(BUILDENV) \
		$(MAKE) CPPFLAGS="$(CXXFLAGS) -I$(targetprefix)/include/ncurses -D__GNU_LIBRARY__" top ps/ps && \
		@INSTALL_procps@
	@CLEANUP_procps@
	touch $@

$(DEPDIR)/udev: bootstrap @DEPENDS_udev@
	@PREPARE_udev@
	cd @DIR_udev@ && \
	       $(BUILDENV) \
	       CROSS=$(target)- \
	       $(MAKE) && \
	       @INSTALL_udev@
	       @CLEANUP_udev@
	touch $@

$(DEPDIR)/watchdog: bootstrap @DEPENDS_watchdog@
	@PREPARE_watchdog@
	cd @DIR_watchdog@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--cache-file=/dev/null && \
		$(MAKE) all && \
		@INSTALL_watchdog@
	@CLEANUP_watchdog@
	touch $@

$(DEPDIR)/mrouted: bootstrap @DEPENDS_mrouted@
	@PREPARE_mrouted@
	cd @DIR_mrouted@ && \
	    $(BUILDENV) \
	    $(MAKE) all && \
	    $(INSTALL) -m755 mrouted $(targetprefix)/bin/mrouted && \
	    $(INSTALL) -m755 map-mbone $(targetprefix)/bin/map-mbone && \
	    $(INSTALL) -m755 mrinfo $(targetprefix)/bin/mrinfo
	@CLEANUP_mrouted@
	touch $@

if TARGETRULESET_FLASH

flash-mrouted: $(flashprefix)/root/bin/mrouted

$(flashprefix)/root/bin/mrouted: $(flashprefix)/root plugins mrouted | $(flashprefix)/root
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/dreamdata.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/dreamdata.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/var/tuxbox/config/dreamdata.xml $(flashprefix)/root/var/tuxbox/config/
	$(INSTALL) $(targetprefix)/bin/mrouted $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@
endif
