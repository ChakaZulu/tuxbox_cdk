EXTRA_DIST = \
	rcS.in start start_lcars start_neutrino start_sshd.in

FILES = \
	rcS start start_lcars start_neutrino start_sshd

all-local: $(FILES)

install-data-local: $(FILES)
	install -d $(targetprefix)/etc/init.d
	@for i in $(FILES) ; do \
		install -m755 $$i $(targetprefix)/etc/init.d ; \
	done

distclean-local:
	rm -f rcS start_sshd

