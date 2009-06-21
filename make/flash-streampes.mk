## flash-dvb-tools
## TODO: fix if possible

flash-streampes: $(appsdir)/dvb/tools/stream/streampes $(appsdir)/dvb/zapit/src/zapit | $(flashprefix)/root
	$(INSTALL) $(appsdir)/dvb/tools/stream/streamsec $(flashprefix)/root/sbin
	$(INSTALL) $(appsdir)/dvb/tools/stream/streamts $(flashprefix)/root/sbin
	$(INSTALL) $(appsdir)/dvb/tools/stream/streampes $(flashprefix)/root/sbin
if BOXTYPE_DREAMBOX
	$(INSTALL) $(appsdir)/dvb/tools/stream/udpstreampes $(flashprefix)/root/sbin
else
	$(INSTALL) $(appsdir)/dvb/tools/stream/udpstreamts $(flashprefix)/root/sbin
	$(INSTALL) $(appsdir)/dvb/zapit/src/.libs/udpstreampes $(flashprefix)/root/sbin
endif
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@
