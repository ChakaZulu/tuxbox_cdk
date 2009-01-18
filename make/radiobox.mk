# tuxbox/radiobox

$(appsdir)/tuxbox/radiobox/config.status: bootstrap libboost libcurl libfreetype libmad libid3tag libvorbisidec libtuxbox misc_libs tuxbox_libs misc_tools $(TARGET_LUFS) lirc
	cd $(appsdir)/tuxbox/radiobox && $(CONFIGURE)

radiobox: $(appsdir)/tuxbox/radiobox/config.status
	$(MAKE) -C $(appsdir)/tuxbox/radiobox all install

if TARGETRULESET_FLASH
flash-radiobox: $(flashprefix)/root-radiobox

$(flashprefix)/root-radiobox: $(appsdir)/tuxbox/radiobox/config.status
	$(MAKE) -C $(appsdir)/tuxbox/radiobox all install prefix=$@
	touch $@
	@TUXBOX_CUSTOMIZE@

endif

