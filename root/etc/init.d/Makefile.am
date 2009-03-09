EXTRA_DIST = \
	rcS.m4 start start_enigma start_lcars start_neutrino start_sshd halt start_radiobox

FILES_EXEC = \
	rcS start start_enigma start_lcars start_neutrino start_sshd halt start_upnp initialize start_radiobox

if ENABLE_AUTOMOUNT
FILES_EXEC += start_automount
endif

FILES_FLASH_RO_EXEC = \
	rcS rcS.insmod start start_sshd halt initialize

FILES_FLASH_RW_EXEC = \
	start_enigma start_lcars start_neutrino start start_upnp start_radiobox

if ENABLE_AUTOMOUNT
FILES_FLASH_RW_EXEC += start_automount
endif

DIR = /etc/init.d

CLEANFILES = rcS rcS.insmod

include $(top_srcdir)/root/Makefile.inc

if KERNEL26
KERNEL_ARGS=--define=use_kernel_26
endif

COMMON_ARGS=--define=customizationsdir=$(customizationsdir) $(KERNEL_ARGS)

rcS: rcS.m4
	m4 $(COMMON_ARGS) $< > $@
	chmod 755 $@

rcS.insmod: rcS.m4
	m4 $(COMMON_ARGS) --define=insmod $< > $@
	chmod 755 $@
