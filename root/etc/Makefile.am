SUBDIRS = init.d network

EXTRA_DIST = \
	fstab.in group host.conf hostname hosts inetd.conf inittab \
	mime.types modules.conf.in nsswitch.conf passwd profile protocols \
	resolv.conf services termcap \
	cables.xml satellites.xml

FILES = \
	fstab group host.conf hostname hosts inetd.conf inittab \
	mime.types modules.conf nsswitch.conf passwd profile protocols \
	resolv.conf services termcap \
	cables.xml satellites.xml

all-local: $(FILES)

install-data-local: $(FILES)
	install -d $(targetprefix)/etc
	@for i in $(FILES) ; do \
		if [ "$(FORCE)" -o ! -e $(targetprefix)/etc/$$i ] ; then \
			echo "install -m644 $$i $(targetprefix)/etc" ; \
			install -m644 $$i $(targetprefix)/etc ; \
		fi ; \
	done

distclean-local:
	-rm -f fstab modules.conf

