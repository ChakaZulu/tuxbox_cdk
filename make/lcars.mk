# tuxbox/lcars

$(appsdir)/tuxbox/lcars/config.status: bootstrap libcurl libfreetype $(targetprefix)/include/tuxbox/plugin.h libcommoncplusplus
	cd $(appsdir)/tuxbox/lcars && $(CONFIGURE)

lcars: $(appsdir)/tuxbox/lcars/config.status
	$(MAKE) -C $(appsdir)/tuxbox/lcars all install

if TARGETRULESET_FLASH
# Untested! 
flash-lcars: $(flashprefix)/root-lcars

$(flashprefix)/root-lcars: $(appsdir)/tuxbox/lcars/config.status
	$(MAKE) -C $(appsdir)/tuxbox/lcars all install prefix=$@
	touch $@
	@TUXBOX_CUSTOMIZE@

endif
