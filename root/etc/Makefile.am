SUBDIRS = init.d

EXTRA_DIST = \
	fstab group host.conf hostname hosts inetd.conf inittab issue.net \
	mime.types modules.conf.in nsswitch.conf passwd profile protocols \
	resolv.conf services termcap

FILES = \
	fstab group host.conf hostname hosts inetd.conf inittab issue.net \
	mime.types modules.conf nsswitch.conf passwd profile protocols \
	resolv.conf services termcap

install-data-local:
	install -d $(targetprefix)/etc
	@for i in $(FILES) ; do \
		install -m644 $$i $(targetprefix)/etc ; \
	done
