$(flashprefix):
	$(INSTALL) -d $@

$(flashprefix)/root: bootstrap $(wildcard root-local.sh) | $(flashprefix)
	rm -rf $@
	$(INSTALL) -d $@/bin
	$(INSTALL) -d $@/dev
	$(INSTALL) -d $@/lib/tuxbox
if !BOXTYPE_DREAMBOX
	$(INSTALL) -d $@/mnt
endif
	$(INSTALL) -d $@/proc
	$(INSTALL) -d $@/sbin
	$(INSTALL) -d $@/share/tuxbox
	$(INSTALL) -d $@/share/fonts
	$(INSTALL) -d $@/var/tuxbox/config
	$(INSTALL) -d $@/var/etc
	$(INSTALL) -d $@/tmp
	$(INSTALL) -d $@/etc/init.d
	$(INSTALL) -d $@/root
if KERNEL26
	$(INSTALL) -d $@/sys
endif
	ln -s /tmp $@/var/run
	ln -s /tmp $@/var/tmp
if ENABLE_IDE
	$(INSTALL) -d $@/hdd
endif
	$(MAKE) $@/etc/update.urls

	$(MAKE) flash-tuxinfo
if BOXTYPE_DBOX2
	$(MAKE) flash-tools_misc
	$(MAKE) flash-fcp
	$(MAKE) flash-camd2
	$(MAKE) flash-ucodes
endif
	$(MAKE) flash-config
	$(MAKE) flash-busybox
	$(MAKE) flash-ftpd
	$(MAKE) flash-satfind
	$(MAKE) flash-streampes
if ENABLE_FS_LUFS
	$(MAKE) flash-lufsd
endif
	$(MAKE) flash-etherwake
	$(MAKE) flash-tuxmail
	$(MAKE) flash-tuxtxt
	$(MAKE) flash-tuxcom
	$(MAKE) flash-vncviewer
	$(MAKE) flash-dvbsub
	$(MAKE) flash-fx2-plugins
	$(MAKE) flash-lcdip
if ENABLE_AUTOMOUNT
	$(MAKE) flash-automount
endif
if KERNEL26
	$(MAKE) flash-makedevices
	$(MAKE) flash-hotplug
endif
if ENABLE_DOSFSTOOLS
	$(MAKE) flash-dosfstools
endif
if ENABLE_LIRC
	$(MAKE) flash-lircd
endif
if ENABLE_CDKVCINFO
	$(MAKE) flash-cdkVcInfo
endif
if ENABLE_XFS
	$(MAKE) flash-xfsprogs
endif
if ENABLE_REISERFS
	$(MAKE) flash-reiserfsprogs
endif
if ENABLE_NFSSERVER
	$(MAKE) flash-nfsserver
endif
if ENABLE_SAMBASERVER
	$(MAKE) flash-sambaserver
endif
if ENABLE_FS_SMBFS
	$(MAKE) flash-smbmount
endif
if ENABLE_GERMAN_KEYMAPS
	$(MAKE) flash-german-keymaps
endif
if ENABLE_SQLITE
	$(MAKE) flash-sqlite
endif
	$(MAKE) flash-defaultlocale
	$(MAKE) flash-version
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@

