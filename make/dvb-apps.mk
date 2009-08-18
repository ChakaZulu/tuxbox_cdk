#######################
#
#  DVB apps
#

dvb_apps: dvbdate dvbstream dvbtext dvbtune vls

$(DEPDIR)/dvbdate: bootstrap @DEPENDS_dvbdate@
	@PREPARE_dvbdate@
	cd @DIR_dvbdate@ && \
		$(MAKE) dvbdate \
			$(BUILDENV) \
			CPPFLAGS="-I$(driverdir)/dvb/include -DNEWSTRUCT" && \
		@INSTALL_dvbdate@
	@CLEANUP_dvbdate@
	touch $@

$(DEPDIR)/dvbstream: bootstrap @DEPENDS_dvbstream@
	@PREPARE_dvbstream@
	cd @DIR_dvbstream@ && \
		$(MAKE) dvbstream rtpfeed\
			INCS="-I$(driverdir)/dvb/include -DNEWSTRUCT" \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" && \
		@INSTALL_dvbstream@
	@CLEANUP_dvbstream@
	touch $@

$(DEPDIR)/dvbtext: bootstrap @DEPENDS_dvbtext@
	@PREPARE_dvbtext@
	cd @DIR_dvbtext@ && \
		$(target)-gcc $(TARGET_CFLAGS) -I$(driverdir)/dvb/include -DNEWSTRUCT -o dvbtext dvbtext.c && \
		@INSTALL_dvbtext@
	@CLEANUP_dvbtext@
	touch $@

$(DEPDIR)/dvbtune: bootstrap @DEPENDS_dvbtune@
	@PREPARE_dvbtune@
	cd @DIR_dvbtune@ && \
		$(MAKE) \
			$(BUILDENV) \
			CPPFLAGS="-I$(DVB_INCLUDESDIR) -DNEWSTRUCT" && \
		@INSTALL_dvbtune@
	@CLEANUP_dvbtune@
	touch $@

$(DEPDIR)/vls: bootstrap libdvbpsi @DEPENDS_vls@
	@PREPARE_vls@
	cd @DIR_vls@ && \
		$(BUILDENV) \
		CCFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-dvd \
			--with-dvb=$(driverdir)/dvb/include && \
		$(MAKE) all && \
		@INSTALL_vls@
	@CLEANUP_vls@
	touch $@

# dvb/dvbsnoop

$(appsdir)/dvb/dvbsnoop/config.status: bootstrap
	cd $(appsdir)/dvb/dvbsnoop && $(CONFIGURE)

$(DEPDIR)/dvbsnoop: $(appsdir)/dvb/dvbsnoop/config.status
	$(MAKE) -C $(appsdir)/dvb/dvbsnoop all install

if TARGETRULESET_FLASH
flash-dvbsnoop: $(appsdir)/dvb/dvbsnoop/config.status $(flashprefix)/root
	$(MAKE) -C $(appsdir)/dvb/dvbsnoop all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@
endif

# dvb/libdvb++

$(appsdir)/dvb/libdvb++/config.status: bootstrap libdvbsi++
	cd $(appsdir)/dvb/libdvb++ && $(CONFIGURE) CPPFLAGS="$(CPPFLAGS) -I$(driverdir)/dvb/include"

$(DEPDIR)/libdvb++: $(appsdir)/dvb/libdvb++/config.status
	$(MAKE) -C $(appsdir)/dvb/libdvb++ all install
	touch $@

# dvb/libdvbsi++

$(appsdir)/dvb/libdvbsi++/config.status: bootstrap
	cd $(appsdir)/dvb/libdvbsi++ && $(CONFIGURE) CPPFLAGS="$(CPPFLAGS) -I$(driverdir)/dvb/include"

$(DEPDIR)/libdvbsi++: $(appsdir)/dvb/libdvbsi++/config.status
	$(MAKE) -C $(appsdir)/dvb/libdvbsi++ all install
	touch $@

# dvb/tools

# This file serves as a marker
$(appsdir)/dvb/tools/stream/streampes:
	$(MAKE) dvb_tools

$(appsdir)/dvb/tools/config.status: bootstrap $(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc
	cd $(appsdir)/dvb/tools && $(CONFIGURE)

dvb_tools: $(appsdir)/dvb/tools/config.status
	$(MAKE) -C $(appsdir)/dvb/tools all install
