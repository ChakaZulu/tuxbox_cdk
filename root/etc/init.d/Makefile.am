EXTRA_DIST = \
	rcS.in start start_enigma start_lcars start_neutrino start_sshd.in

FILES = \
	rcS start start_enigma start_lcars start_neutrino start_sshd

all-local: $(FILES)

install-data-local: $(FILES)
	install -d $(targetprefix)/etc/init.d
	@for i in $(FILES) ; do \
		if [ "$(FORCE)" -o ! -e $(targetprefix)/etc/init.d/$$i ] ; then \
			echo "install -m755 $$i $(targetprefix)/etc/init.d" ; \
			install -m755 $$i $(targetprefix)/etc/init.d ; \
		fi ; \
	done

distclean-local:
	rm -f rcS start_sshd

