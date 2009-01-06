# dvb/config

# cables.xml, satellites.xml

$(appsdir)/dvb/config/config.status:
	cd $(appsdir)/dvb/config && $(CONFIGURE)

config: $(appsdir)/dvb/config/config.status
	$(MAKE) -C $(appsdir)/dvb/config all install

if TARGETRULESET_FLASH

flash-config: $(appsdir)/dvb/config/config.status $(flashprefix)/root
	$(MAKE) -C $(appsdir)/dvb/config all install datadir=$(flashprefix)/root/share
	@FLASHROOTDIR_MODIFIED@

endif
