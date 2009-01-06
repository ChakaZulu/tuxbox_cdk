# tuxbox/libs

# This file serves as a marker for tuxbox_libs
$(targetprefix)/lib/pkgconfig/tuxbox-tuxtxt.pc:
	$(MAKE) tuxbox_libs

$(appsdir)/tuxbox/libs/config.status: bootstrap libfreetype libpng libtuxbox
	cd $(appsdir)/tuxbox/libs && $(CONFIGURE)

tuxbox_libs: $(appsdir)/tuxbox/libs/config.status
	$(MAKE) -C $(appsdir)/tuxbox/libs all install

.PHONY: tuxbox_libs
