EXTRA_DIST = \
	rcS.m4 start_enigma start_lcars start_neutrino start_sshd halt start_radiobox start_esound start_vdr

FILES_EXEC = \
	rcS start_enigma start_lcars start_neutrino start_sshd start_upnp initialize start_radiobox start_esound start_vdr

if BOXTYPE_IPBOX
FILES_EXEC += start.ipbox halt.ipbox
else
FILES_EXEC += start halt
endif

if BOXTYPE_IPBOX
FILES_EXEC += crond.ipbox init1.ipbox syslogd.ipbox
if BOXMODEL_IP350
FILES_EXEC += usb.ipbox
endif
if ENABLE_FS_CIFS
FILES_EXEC += cifs.ipbox
endif
if ENABLE_IDE
FILES_EXEC += ide.ipbox
endif
if ENABLE_MMC
FILES_EXEC += mmc.ipbox
endif
if ENABLE_NFSSERVER
FILES_EXEC += nfs.ipbox
endif
if ENABLE_FS_SMBFS
FILES_EXEC += smbfs.ipbox
endif
endif

if ENABLE_AUTOMOUNT
if BOXTYPE_IPBOX
FILES_EXEC += start_automount.ipbox
else
FILES_EXEC += start_automount
endif
endif

FILES_FLASH_RO_EXEC = \
	start_sshd initialize

if BOXTYPE_IPBOX
FILES_FLASH_RO_EXEC += rcS.ipbox halt.ipbox start.ipbox
else
FILES_FLASH_RO_EXEC += rcS rcS.insmod halt start
endif

if BOXTYPE_IPBOX
FILES_FLASH_RO_EXEC += crond.ipbox init1.ipbox syslogd.ipbox
if BOXMODEL_IP350
FILES_FLASH_RO_EXEC += usb.ipbox
endif
if ENABLE_FS_CIFS
FILES_FLASH_RO_EXEC += cifs.ipbox
endif
if ENABLE_IDE
FILES_FLASH_RO_EXEC += ide.ipbox
endif
if ENABLE_MMC
FILES_FLASH_RO_EXEC += mmc.ipbox
endif
if ENABLE_NFSSERVER
FILES_FLASH_RO_EXEC+= nfs.ipbox
endif
if ENABLE_FS_SMBFS
FILES_FLASH_RO_EXEC += smbfs.ipbox
endif
endif

FILES_FLASH_RW_EXEC = \
	start_enigma start_lcars start_neutrino start start_upnp start_radiobox

if ENABLE_ESD
FILES_FLASH_RW_EXEC += start_esound
endif

if ENABLE_AUTOMOUNT
if BOXTYPE_IPBOX
FILES_FLASH_RW_EXEC += start_automount.ipbox
else
FILES_FLASH_RW_EXEC += start_automount
endif
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
