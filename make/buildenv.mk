if ENABLE_CCACHE
PATH := $(hostprefix)/ccache-bin:$(hostprefix)/bin:$(PATH)
else
PATH := $(hostprefix)/bin:$(PATH)
endif

BUILDENV := \
	AR=$(target)-ar \
	AS=$(target)-as \
	CC=$(target)-gcc \
	CXX=$(target)-g++ \
	NM=$(target)-nm \
	RANLIB=$(target)-ranlib \
	CFLAGS="$(TARGET_CFLAGS)" \
	CXXFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH=$(targetprefix)/lib/pkgconfig

DEPDIR = .deps

VPATH = $(DEPDIR)

CONFIGURE_OPTS = \
	--build=$(build) \
	--host=$(target) \
	--prefix=$(targetprefix) \
	--with-driver=$(driverdir) \
	--with-boxtype=$(BOXTYPE) \
	--with-target=cdk
if BOXTYPE_DREAMBOX
CONFIGURE_OPTS += --with-boxmodel=$(BOXMODEL) \
		  --with-dvbincludes=$(driverdir)/oldapi/include
endif
if BOXTYPE_IPBOX
CONFIGURE_OPTS += --with-boxmodel=$(BOXMODEL) \
		  --with-dvbincludes=$(driverdir)/oldapi/include
endif
if BOXTYPE_DBOX2
if KERNEL26
CONFIGURE_OPTS += \
	--with-dvbincludes=$(targetprefix)/include
else
CONFIGURE_OPTS += \
	--with-dvbincludes=$(driverdir)/dvb/include
endif
endif

if MAINTAINER_MODE
CONFIGURE_OPTS_MAINTAINER = \
	--enable-maintainer-mode
endif

if TARGETRULESET_FLASH
CONFIGURE_OPTS_DEBUG = \
	--without-debug
if ENABLE_LZMA
MKSQUASHFS = $(hostprefix)/bin/mksquashfs-lzma
else
MKSQUASHFS = $(hostprefix)/bin/mksquashfs-nolzma
endif
endif

if ENABLE_UPNP
CONFIGURE_OPTS_UPNP = \
	--enable-upnp
endif

if ENABLE_FLAC
CONFIGURE_OPTS_FLAC =  \
	--enable-flac
endif

if ENABLE_IDE
CONFIGURE_OPTS_IDE =  \
	--enable-ide
endif

if ENABLE_CCACHE
CONFIGURE_OPTS_CCACHE = \
	--enable-ccache
endif

if ENABLE_SQLITE
CONFIGURE_OPTS_SQLITE = \
	--enable-sqlite
endif

if DISABLE_UPDATE_HTTP
CONFIGURE_OPTS_HTTP_UPDATE = \
	--disable-http-update
endif

CONFIGURE = \
	./autogen.sh && \
	CC=$(target)-gcc \
	CXX=$(target)-g++ \
	CFLAGS="-Wall $(TARGET_CFLAGS)" \
	CXXFLAGS="-Wall $(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure $(CONFIGURE_OPTS) \
	$(CONFIGURE_OPTS_MAINTAINER) \
	$(CONFIGURE_OPTS_DEBUG) \
	$(CONFIGURE_OPTS_UPNP) \
	$(CONFIGURE_OPTS_FLAC) \
	$(CONFIGURE_OPTS_IDE) \
	$(CONFIGURE_OPTS_SQLITE) \
	$(CONFIGURE_OPTS_CCACHE) \
	$(CONFIGURE_OPTS_HTTP_UPDATE)

ACLOCAL_AMFLAGS = -I .

CONFIG_STATUS_DEPENDENCIES = \
	$(top_srcdir)/rules.pl \
	$(top_srcdir)/rules-install $(top_srcdir)/rules-install-flash \
	$(top_srcdir)/rules-make \
	Makefile-archive

