# Zapit

$(appsdir)/dvb/zapit/src/zapit:
	$(MAKE) zapit

$(appsdir)/dvb/zapit/config.status: bootstrap $(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc
	cd $(appsdir)/dvb/zapit && $(CONFIGURE)

zapit: $(appsdir)/dvb/zapit/config.status
	$(MAKE) -C $(appsdir)/dvb/zapit all install

.PHONY: zapit
