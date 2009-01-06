# dvb/dvbsnoop

$(appsdir)/dvb/dvbsnoop/config.status: bootstrap
	cd $(appsdir)/dvb/dvbsnoop && $(CONFIGURE) CPPFLAGS="$(CPPFLAGS) -I$(driverdir)/dvb/include"

$(DEPDIR)/dvbsnoop: $(appsdir)/dvb/dvbsnoop/config.status
	$(MAKE) -C $(appsdir)/dvb/dvbsnoop all install

if TARGETRULESET_FLASH
flash-dvbsnoop: $(appsdir)/dvb/dvbsnoop/config.status $(flashprefix)/root
	$(MAKE) -C $(appsdir)/dvb/dvbsnoop all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@
endif
