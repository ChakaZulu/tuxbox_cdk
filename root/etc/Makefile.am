SUBDIRS = init.d

EXTRA_DIST = \
	fstab.in group host.conf hostname hosts inetd.conf inittab issue.net \
	mime.types modules.conf.in nsswitch.conf passwd profile protocols \
	resolv.conf services termcap thttpd.conf

FILES = \
	fstab group host.conf hostname hosts inetd.conf inittab issue.net \
	mime.types modules.conf nsswitch.conf passwd profile protocols \
	resolv.conf services termcap thttpd.conf

all-local: $(FILES)

install-data-local: $(FILES)
	install -d $(targetprefix)/etc
	@for i in $(FILES) ; do \
		install -m644 $$i $(targetprefix)/etc ; \
	done

distclean-local:
	-rm -f fstab modules.conf

