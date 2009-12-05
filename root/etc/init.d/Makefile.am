if BOXTYPE_DBOX2

FILES_FLASH_RW_EXEC = \
	start_neutrino start_enigma

if ENABLE_ESD
FILES_FLASH_RW_EXEC += \
	start_esound
endif

FILES_FLASH_RW_EXEC_START =

FILES_FLASH_RO_EXEC = \
	functions rcS rcK initialize

FILES_FLASH_RO_EXEC_START = \
	10network \
	10rtc \
	15syslogd \
	17loadkeys \
	18openntpd \
	18rdate \
	20inetd \
	25cdkVcInfo \
	30dropbear \
	30ser2net \
	40tuxcald \
	40tuxmaild \
	40tuxclockd \
	99gui

if KERNEL26
FILES_FLASH_RO_EXEC += sysinit
FILES_FLASH_RO_EXEC_START += 05drivers
else
FILES_FLASH_RO_EXEC += sysinit.dbox24
FILES_FLASH_RO_EXEC_START += 05drivers.dbox24
endif

if ENABLE_LIRC
FILES_FLASH_RO_EXEC_START += 16lircd
endif

if ENABLE_AUTOMOUNT
FILES_FLASH_RO_EXEC_START += 30autofs
endif

if ENABLE_OPENVPN
FILES_FLASH_RO_EXEC_START += 30openvpn
endif

if ENABLE_SAMBASERVER
FILES_FLASH_RO_EXEC_START += 31sambaserver
endif

if ENABLE_NFSSERVER
FILES_FLASH_RO_EXEC_START += 31nfsserver
endif

FILES_EXEC_START = \
	$(FILES_FLASH_RO_EXEC_START) \
	$(FILES_FLASH_RW_EXEC_START)

else

FILES_FLASH_RO_EXEC = \
	start_sshd initialize

FILES_FLASH_RO_EXEC += rcS.ipbox halt.ipbox start.ipbox initialize

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
FILES_FLASH_RO_EXEC += nfs.ipbox
endif
if ENABLE_FS_SMBFS
FILES_FLASH_RO_EXEC += smbfs.ipbox
endif

FILES_FLASH_RW_EXEC = \
	start_enigma start_lcars start_neutrino.ipbox start start_upnp start_radiobox

if ENABLE_ESD
FILES_FLASH_RW_EXEC += start_esound
endif
if ENABLE_AUTOMOUNT
FILES_FLASH_RW_EXEC += start_automount.ipbox
endif

endif

FILES_EXEC = \
	$(FILES_FLASH_RO_EXEC) \
	$(FILES_FLASH_RW_EXEC)

DIR = /etc/init.d

include $(top_srcdir)/root/Makefile.inc
