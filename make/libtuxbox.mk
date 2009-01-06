# tuxbox/libtuxbox

# This file serves as a marker for libtuxbox
$(targetprefix)/lib/pkgconfig/tuxbox.pc:
	$(MAKE) libtuxbox

$(appsdir)/tuxbox/libtuxbox/config.status: bootstrap
	cd $(appsdir)/tuxbox/libtuxbox && $(CONFIGURE)

libtuxbox: $(appsdir)/tuxbox/libtuxbox/config.status
	$(MAKE) -C $(appsdir)/tuxbox/libtuxbox all install

