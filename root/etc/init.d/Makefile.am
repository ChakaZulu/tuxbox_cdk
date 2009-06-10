EXTRA_DIST = \
	rcS.m4 start start_enigma start_lcars start_neutrino start_sshd halt start_radiobox start_esound

FILES_EXEC = \
	rcS start start_enigma start_lcars start_neutrino start_sshd halt start_upnp initialize start_radiobox start_esound

if ENABLE_AUTOMOUNT
FILES_EXEC += start_automount
endif

FILES_FLASH_RO_EXEC = \
	rcS rcS.insmod start start_sshd halt initialize

FILES_FLASH_RW_EXEC = \
	start_enigma start_lcars start_neutrino start start_upnp start_radiobox start_esound

if ENABLE_AUTOMOUNT
FILES_FLASH_RW_EXEC += start_automount
endif

DIR = /etc/init.d

CLEANFILES = rcS rcS.insmod

include $(top_srcdir)/root/Makefile.inc

RCS_ARGS = --define=customizationsdir=$(customizationsdir)

if KERNEL26
RCS_ARGS += --define=use_kernel_26
endif

rcS: rcS.m4
	m4 $(RCS_ARGS) $< > $@
	chmod 755 $@

rcS.insmod: rcS.m4
	m4 $(RCS_ARGS) --define=insmod $< > $@
	chmod 755 $@
