if ENABLE_NFSSERVER
EXPORTS=exports
endif

if ENABLE_SAMBASERVER
if BOXTYPE_IPBOX
SMBCONF=smb.conf.ipbox
else
SMBCONF=smb.conf
endif
SMBPASSWD=smbpasswd
endif

SUBDIRS = init.d network


FILES_FLASH_RO = \
	fstab host.conf inittab mime.types nsswitch.conf \
	protocols termcap timezone.xml

if BOXTYPE_IPBOX
FILES_FLASH_RO += rpc.ipbox
endif

FILES_FLASH_RW = \
	group hostname hosts inetd.conf passwd resolv.conf services modules.conf \
	$(EXPORTS) $(SMBCONF) $(SMBPASSWD)

if BOXTYPE_IPBOX
FILES_FLASH_RW += profile.ipbox
else
FILES_FLASH_RW += profile
endif

if ENABLE_AUTOMOUNT
FILES_FLASH_RW += auto.net
endif

FILES = \
	$(FILES_FLASH_RO) $(FILES_FLASH_RW)

EXTRA_DIST = $(FILES)

DIR = /etc

include $(top_srcdir)/root/Makefile.inc
