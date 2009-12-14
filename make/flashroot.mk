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

if BOXTYPE_DBOX2
	$(MAKE) flash-tuxinfo
	$(MAKE) flash-camd2
	$(MAKE) flash-ucodes
	$(MAKE) flash-satfind
	$(MAKE) flash-rtc
endif
	$(MAKE) flash-tools_misc
	$(MAKE) flash-fcp
	$(MAKE) flash-config
	$(MAKE) flash-busybox
	$(MAKE) flash-ftpd
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
if ENABLE_FX2PLUGINS
	$(MAKE) flash-fx2-plugins
endif
if BOXTYPE_DREAMBOX
# TODO: pip and mosaic only work with neutrino...
	$(MAKE) flash-pip
	$(MAKE) flash-mosaic
if ENABLE_IDE
	$(MAKE) flash-e2fsprogs
	$(MAKE) flash-sfdisk
endif
	$(MAKE) flash-dvbsnoop
endif
if ENABLE_AUTOMOUNT
	$(MAKE) flash-automount
endif
if BOXTYPE_DBOX2
if KERNEL26
# those right now only make sense on dbox2 since the other platforms use devfs
	$(MAKE) flash-makedevices
	$(MAKE) flash-hotplug
endif
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
if ENABLE_OPENVPN
	$(MAKE) flash-openvpn
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
if ENABLE_IPKG
	$(MAKE) flash-ipkg
endif
	$(MAKE) flash-defaultlocale
	$(MAKE) flash-version
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@

