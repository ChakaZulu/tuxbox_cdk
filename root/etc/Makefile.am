SUBDIRS = init.d network

EXTRA_DIST = \
	fstab group host.conf hostname hosts inetd.conf inittab \
	mime.types modules.conf nsswitch.conf passwd profile protocols \
	resolv.conf services termcap timezone.xml

FILES = \
	fstab group host.conf hostname hosts inetd.conf inittab \
	mime.types modules.conf nsswitch.conf passwd profile protocols \
	resolv.conf services termcap timezone.xml

FILES_FLASH_RO = \
	fstab host.conf inittab mime.types modules.conf-flash nsswitch.conf \
	protocols termcap timezone.xml

FILES_FLASH_RW = \
	group hostname hosts inetd.conf passwd profile resolv.conf services

DIR = /etc

include $(top_srcdir)/root/Makefile.inc
