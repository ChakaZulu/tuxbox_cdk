# dvb/tools

# This file serves as a marker
$(appsdir)/dvb/tools/stream/streampes:
	$(MAKE) dvb_tools

$(appsdir)/dvb/tools/config.status: bootstrap $(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc
	cd $(appsdir)/dvb/tools && $(CONFIGURE)

dvb_tools: $(appsdir)/dvb/tools/config.status
	$(MAKE) -C $(appsdir)/dvb/tools all install
