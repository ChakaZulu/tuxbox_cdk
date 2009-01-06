# tuxbox/tools

# I have thrown out pluginx, then no longer dependent of plugins
# Also camd (replaced by camd2) nuked.
# TODO: reenable pluginx (possibly somewhere else in the source tree)

# tuxbox_tools installs a lot of different tools, most of which are
# pretty special, some (like switch) absolutely essential. For this
# reason, there is no target flash-tuxbox_tools.

$(appsdir)/tuxbox/tools/config.status: bootstrap $(targetprefix)/lib/pkgconfig/tuxbox.pc
	cd $(appsdir)/tuxbox/tools && $(CONFIGURE)

tuxbox_tools: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools all install

# These are really sub-targets of tuxbox_tools

tuxinfo: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/tuxinfo install


camd2: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/camd install

satfind: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/satfind install

cdkVcInfo: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/cdkVcInfo install

kb2rcd: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/kb2rcd install

if TARGETRULESET_FLASH

flash-tuxinfo: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/tuxinfo install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-camd2: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/camd install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-satfind: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/satfind install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-cdkVcInfo: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/cdkVcInfo install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-kb2rcd: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/kb2rcd install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

endif


################################################################
# tools_misc is not misc_tools misspelled ... 
switch \
tools_misc: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/misc install

if TARGETRULESET_FLASH

# The directory $(appsdir)/tuxbox/tools/misc contains several tools;
# we should probaly not install all in an 8MiB image.
flash-tools_misc: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/misc install prefix=$(flashprefix)/root  bin_PROGRAMS="switch saa rcsim"
	@FLASHROOTDIR_MODIFIED@

# This target install every program in $(appsdir)/tuxbox/tools/misc
flash-tools_misc-all: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/misc install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@
endif 

################################################################
# $(appsdir)/tuxbox/tools/test
$(targetprefix)/bin/datarate \
$(targetprefix)/bin/fp_reg \
$(targetprefix)/bin/showfreq \
$(targetprefix)/bin/showfreq_qpsk \
$(targetprefix)/bin/test_event \
$(targetprefix)/bin/test_lcd \
$(targetprefix)/bin/wakeup: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/test install

# $(appsdir)/tuxbox/tools/graphics
$(targetprefix)/bin/fbtest \
$(targetprefix)/bin/vgrab \
$(targetprefix)/bin/overlay \
$(targetprefix)/bin/unsquasher \
$(targetprefix)/bin/yuv2ppm: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/graphics install

################################################################

if KERNEL26
$(appsdir)/tuxbox/tools/hotplug/config.status: bootstrap
	cd $(appsdir)/tuxbox/tools/hotplug && $(CONFIGURE)

$(DEPDIR)/tuxbox_hotplug: $(appsdir)/tuxbox/tools/hotplug/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/hotplug all install
	touch $@

# this target does nothing presently
$(targetprefix)/sbin/hotplug: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/hotplug install

if TARGETRULESET_FLASH
flash-hotplug:  $(appsdir)/tuxbox/tools/hotplug/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/hotplug all install prefix="$(flashprefix)/root"
	@FLASHROOTDIR_MODIFIED@
endif
endif

.PHONY: tuxbox_tools tuxinfo camd2 satfind flash-tuxinfo flash-camd2 \
	flash-satfind switch tools_misc flash-tools_misc
