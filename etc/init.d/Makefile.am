EXTRA_DIST = \
	rcS.in start start_lcars start_neutrino start_sshd

FILES = \
	rcS start start_lcars start_neutrino start_sshd

install-data-local:
	install -d $(targetprefix)/etc/init.d
	@for i in $(FILES) ; do \
		install -m755 $$i $(targetprefix)/etc/init.d ; \
	done
