# tuxbox/libs

# This file serves as a marker for tuxbox_libs
$(targetprefix)/lib/pkgconfig/tuxbox-tuxtxt.pc:
	$(MAKE) tuxbox_libs

$(appsdir)/tuxbox/libs/config.status: bootstrap libfreetype libpng libtuxbox
	cd $(appsdir)/tuxbox/libs && $(CONFIGURE)

tuxbox_libs: $(appsdir)/tuxbox/libs/config.status
	$(MAKE) -C $(appsdir)/tuxbox/libs all install


# tuxbox/libtuxbox

# This file serves as a marker for libtuxbox
$(targetprefix)/lib/pkgconfig/tuxbox.pc:
	$(MAKE) libtuxbox

$(appsdir)/tuxbox/libtuxbox/config.status: bootstrap
	cd $(appsdir)/tuxbox/libtuxbox && $(CONFIGURE)

libtuxbox: $(appsdir)/tuxbox/libtuxbox/config.status
	$(MAKE) -C $(appsdir)/tuxbox/libtuxbox all install


# misc/libs

# This file serves as a marker for misc_libs
$(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc:
	$(MAKE) misc_libs

$(appsdir)/misc/libs/config.status: bootstrap libz
	cd $(appsdir)/misc/libs && $(CONFIGURE)

misc_libs: $(appsdir)/misc/libs/config.status
	$(MAKE) -C $(appsdir)/misc/libs all install

.PHONY: tuxbox_libs
