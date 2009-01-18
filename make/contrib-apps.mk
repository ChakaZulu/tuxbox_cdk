#######################
#
#   contrib apps
#

if ENABLE_FS_LUFS
TARGET_LUFS=lufs
endif

contrib_apps: bzip2 console_data kbd fbset lirc lsof dropbear ssh tcpdump bonnie $(TARGET_LUFS) kermit wget ncftp screen lzma_utils

CONTRIB_DEPSCLEANUP = rm -f .deps/bzip2 .deps/console_data .deps/kbd .deps/directfb_examples .deps/fbset .deps/lirc .deps/lsof .deps/ssh .deps/tcpdump .deps/bonnie .deps/vdr .deps/lufs .deps/dropbear .deps/kermit .deps/wget .deps/ncftp .deps/screen .deps/lzma_utils

#bzip2
$(DEPDIR)/bzip2: bootstrap @DEPENDS_bzip2@
	@PREPARE_bzip2@
	cd @DIR_bzip2@ && \
	mv Makefile-libbz2_so Makefile && \
		CC=$(target)-gcc \
		$(MAKE) all && \
		@INSTALL_bzip2@
	@CLEANUP_bzip2@
	touch $@

if TARGETRULESET_FLASH
flash-bzip2: $(flashprefix)/root/bin/bzip2

$(flashprefix)/root/bin/bzip2: @DEPENDS_bzip2@ | $(flashprefix)/root
	@PREPARE_bzip2@
	cd @DIR_bzip2@ && \
	mv Makefile-libbz2_so Makefile && \
		CC=$(target)-gcc \
		$(MAKE) all && \
		$(MAKE) install PREFIX=$(flashprefix)/root
	@CLEANUP_bzip2@
	@FLASHROOTDIR_MODIFIED@

endif

#console_data console_tools
$(DEPDIR)/console_data: bootstrap @DEPENDS_console_data@
	@PREPARE_console_data@
	cd @DIR_console_data@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-main_compressor=gzip && \
		@INSTALL_console_data@
	@CLEANUP_console_data@
	touch $@

$(DEPDIR)/console_tools: bootstrap console_data @DEPENDS_console_tools@
	@PREPARE_console_tools@
	cd @DIR_console_tools@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		@INSTALL_console_tools@
	@CLEANUP_console_tools@
	touch $@

$(DEPDIR)/kbd: bootstrap console_data @DEPENDS_kbd@
	@PREPARE_kbd@
	cd @DIR_kbd@ && \
		autoconf && \
		sed -i \
		-e "s:install -s:install:" \
		src/Makefile.in && \
		$(BUILDENV) \
		ac_cv_func_realloc_0_nonnull=yes \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		$(BUILDENV) \
		@INSTALL_kbd@
	@CLEANUP_kbd@
	touch $@

if TARGETRULESET_FLASH 

# This is ugly, very ugly. But I do not know of a completely clean way
# of installing just the minimum.

flash-german-keymaps: $(DEPDIR)/kbd
	$(INSTALL) $(targetprefix)/bin/loadkeys $(flashprefix)/root/bin
	$(INSTALL) -d $(flashprefix)/root/share/keymaps/i386/qwertz
	$(INSTALL) -d $(flashprefix)/root/share/keymaps/i386/include
	$(INSTALL) -m 444 $(targetprefix)/share/keymaps/i386/qwertz/de-latin1-nodeadkeys.kmap.gz $(flashprefix)/root/share/keymaps/i386/qwertz
	$(INSTALL) -m 444 $(targetprefix)/share/keymaps/i386/qwertz/de-latin1.kmap.gz $(flashprefix)/root/share/keymaps/i386/qwertz
	$(INSTALL) -m 444 $(targetprefix)/share/keymaps/i386/include/linux-keys-bare.inc.gz $(flashprefix)/root/share/keymaps/i386/include
	$(INSTALL) -m 444 $(targetprefix)/share/keymaps/i386/include/linux-with-alt-and-altgr.inc.gz $(flashprefix)/root/share/keymaps/i386/include
	$(INSTALL) -m 444 $(targetprefix)/share/keymaps/i386/include/qwertz-layout.inc.gz $(flashprefix)/root/share/keymaps/i386/include
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@

endif

$(DEPDIR)/directfb_examples: bootstrap libdirectfb @DEPENDS_directfb_examples@
	@PREPARE_directfb_examples@
	cd @DIR_directfb_examples@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_directfb_examples@
	@CLEANUP_directfb_examples@
	touch $@


#fbset
$(DEPDIR)/fbset: bootstrap @DEPENDS_fbset@
	@PREPARE_fbset@
	cd @DIR_fbset@ && \
		$(MAKE) \
			$(BUILDENV) && \
		@INSTALL_fbset@
	@CLEANUP_fbset@
	touch $@

#lirc
$(DEPDIR)/lirc: bootstrap @DEPENDS_lirc@ Patches/lirc.diff
	@PREPARE_lirc@
	cd @DIR_lirc@ && \
		$(BUILDENV) \
		mknod=/bin/true \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-devdir=/dev \
			--with-driver=none \
			--with-kerneldir=$(buildprefix)/linux \
			--with-moduledir=$(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
			--without-x && \
		@INSTALL_lirc@
	@CLEANUP_lirc@
	touch $@

if TARGETRULESET_FLASH
flash-lircd: $(flashprefix)/root/sbin/lircd

$(flashprefix)/root/sbin/lircd: lirc
	$(INSTALL) $(targetprefix)/sbin/lircd $@
	$(INSTALL) -d $(targetprefix)/var/tuxbox/config/lirc
	@FLASHROOTDIR_MODIFIED@

endif


#lsof
$(DEPDIR)/lsof: bootstrap @DEPENDS_lsof@
	@PREPARE_lsof@
	cd @DIR_lsof@ && \
	tar xvf @DIR_lsof@_src.tar && \
	cd @DIR_lsof@_src && \
	patch -p1 < ../../Patches/lsof.diff && \
		CROSS_COMPILE=$(target)- \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LSOF_VSTR=$(KERNELVERSION) \
		LINUX_CLIB="-DGLIBCV=202" \
		./Configure -n linux && \
		$(MAKE) all && \
		@INSTALL_lsof@
	@CLEANUP_lsof@
	touch $@

#dropbear
$(DEPDIR)/dropbear: bootstrap libz @DEPENDS_dropbear@ Patches/dropbear-options.h
	@PREPARE_dropbear@
	cd @DIR_dropbear@ && \
		$(BUILDENV) \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-syslog \
			--disable-shadow \
			--disable-lastlog \
			--disable-utmp \
			--disable-utmpx \
			--disable-wtmp \
			--disable-wtmpx && \
		cp ../Patches/dropbear-options.h options.h && \
		$(MAKE) PROGRAMS="dropbear dropbearkey scp" MULTI=1 && \
		mkdir -p $(targetprefix)/var/etc/dropbear && \
		mkdir -p $(targetprefix)/var/.ssh && \
		@INSTALL_dropbear@ && \
		$(target)-strip --strip-all $(targetprefix)/sbin/dropbearmulti
	@CLEANUP_dropbear@
	touch $@

if TARGETRULESET_FLASH

flash-dropbear: $(flashprefix)/root/sbin/dropbearmulti

$(flashprefix)/root/sbin/dropbearmulti: $(DEPDIR)/dropbear | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/sbin/dropbearmulti $(flashprefix)/root/sbin
	for i in dropbear scp dropbearkey; do \
		ln -sf dropbearmulti $(flashprefix)/root/sbin/$$i; done;
	mkdir -p $(flashprefix)/root/var/.ssh
	mkdir -p $(flashprefix)/root/var/etc/dropbear
	ln -sf /var/.ssh $(flashprefix)/root/.ssh
	@FLASHROOTDIR_MODIFIED@

endif

#ssh
$(DEPDIR)/ssh: bootstrap libcrypto libz @DEPENDS_ssh@
	@PREPARE_ssh@
	cd @DIR_ssh@ && \
		$(BUILDENV) \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--sysconfdir=/etc/ssh \
			--without-shadow \
			--with-4in6 \
			--disable-suid-ssh \
			--with-path="/bin:/sbin" \
			--with-privsep-user=sshd \
			--with-privsep-path=/share/empty && \
		$(MAKE) all && \
		@INSTALL_ssh@
	@CLEANUP_ssh@
	touch $@

if TARGETRULESET_FLASH
flash-ssh: $(flashprefix)/root/bin/ssh

$(flashprefix)/root/bin/ssh: $(flashprefix)/root $(DEPDIR)/ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh $(targetprefix)/bin/scp \
		$(targetprefix)/bin/sftp $(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/ssh/ssh_config $(flashprefix)/root/etc/ssh

flash-sshd: $(flashprefix)/root/sbin/sshd

$(flashprefix)/root/sbin/sshd: $(DEPDIR)/ssh | $(flashprefix)/root
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) -d $(flashprefix)/root/libexec
	$(INSTALL) -d $(flashprefix)/root/share/empty
	$(INSTALL) $(targetprefix)/bin/ssh-keygen $(targetprefix)/bin/scp \
		$(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/ssh/* $(flashprefix)/root/etc/ssh
#??#	cp -rd $(targetprefix)/etc/init.d/start_sshd $(flashprefix)/root/etc/init.d/
	$(INSTALL) $(targetprefix)/libexec/sftp-server $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/sbin/sshd $(flashprefix)/root/sbin
	@FLASHROOTDIR_MODIFIED@
endif

#tcpdump
$(DEPDIR)/tcpdump: bootstrap libpcap @DEPENDS_tcpdump@
	@PREPARE_tcpdump@
	cd @DIR_tcpdump@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-smb \
			--disable-ipv6 \
			--without-crypto && \
		$(MAKE) all && \
		@INSTALL_tcpdump@
	@CLEANUP_tcpdump@
	touch $@

#bonnie
$(DEPDIR)/bonnie: bootstrap @DEPENDS_bonnie@
	@PREPARE_bonnie@
	cd @DIR_bonnie@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(hostprefix) && \
		$(MAKE) all WFLAGS= && \
                $(target)-strip -s bonnie++ &&\
		cp bonnie++ $(targetprefix)/sbin/bonnie
	@CLEANUP_bonnie@
	touch $@

if TARGETRULESET_FLASH
flash-bonnie: $(flashprefix)/root/sbin/bonnie

$(flashprefix)/root/sbin/bonnie: bonnie | $(flashprefix)/root
	cp $(targetprefix)/sbin/bonnie $@
	@FLASHROOTDIR_MODIFIED@

endif

#vdr
$(DEPDIR)/vdr: bootstrap @DEPENDS_vdr@
	@PREPARE_vdr@
	cd @DIR_vdr@ && \
		$(BUILDENV) \
		DVBDIR="$(driverdir)/dvb" \
		$(MAKE) all DRIVERDIR=$(driverdir) && \
		$(MAKE) plugins PREFIX=$(prefix) DRIVERDIR=$(driverdir) && \
		@INSTALL_vdr@
	@CLEANUP_vdr@
	touch $@

if ENABLE_FS_LUFS
#lufs
$(DEPDIR)/lufs: bootstrap @DEPENDS_lufs@
	@PREPARE_lufs@
	cd @DIR_lufs@ && \
		$(BUILDENV) \
		aclocal && \
		case `libtoolize --version | head -n 1 | awk '{ print $$(NF); }'` in \
		    0.*|1.*)    libtoolize --force ;; \
		    *)          libtoolize --force --install ;; \
		esac && \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--exec_prefix=$(targetprefix) \
			--disable-kernel-support && \
		$(MAKE) all && \
		@INSTALL_lufs@ && \
		ln -sf ../bin/lufsd $(targetprefix)/sbin/mount.lufs
	@CLEANUP_lufs@
	touch $@

if TARGETRULESET_FLASH
flash-lufsd: $(flashprefix)/root/bin/lufsd

$(flashprefix)/root/bin/lufsd: bootstrap @DEPENDS_lufs@ | $(flashprefix)/root
	@PREPARE_lufs@
	cd @DIR_lufs@ && \
		$(BUILDENV) \
		aclocal && \
		case `libtoolize --version | head -n 1 | awk '{ print $$(NF); }'` in \
		    0.*|1.*)    libtoolize --force ;; \
		    *)          libtoolize --force --install ;; \
		esac && \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(flashprefix)/root \
			--exec_prefix=$(flashprefix)/root \
			--disable-kernel-support && \
		$(MAKE) all install
	rm $(flashprefix)/root/bin/auto.ftpfs
	rm $(flashprefix)/root/bin/auto.sshfs
	rm $(flashprefix)/root/bin/lufsmount
	rm $(flashprefix)/root/bin/lufsumount
	rm $(flashprefix)/root/bin/lussh
	rm $(flashprefix)/root/etc/auto.sshfs
	rm $(flashprefix)/root/etc/auto.ftpfs
	rm $(flashprefix)/root/lib/liblufs-sshfs.*
	ln -sf ../bin/lufsd $(flashprefix)/root/sbin/mount.lufs
	@CLEANUP_lufs@
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@
endif
endif

#kermit
$(DEPDIR)/kermit: bootstrap @DEPENDS_kermit@ libcrypto Patches/kermit.diff
	@echo "Kermit is licensed differently from other software (more restrictively),"
	@echo "see http://www.columbia.edu/kermit/licensing.html"
	@PREPARE_kermit@
	cd @DIR_kermit@ && \
		$(BUILDENV) \
		$(MAKE) tuxbox && \
		@INSTALL_kermit@
	ln -sf ./kermit $(targetprefix)/bin/kermit-sshsub
	[ -d $(targetprefix)/var/lock ] ||  mkdir $(targetprefix)/var/lock
	@CLEANUP_kermit@
	touch $@

#wget
$(DEPDIR)/wget: bootstrap @DEPENDS_wget@
	@PREPARE_wget@
	cd @DIR_wget@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=&& \
		$(MAKE) all && \
		@INSTALL_wget@
	@CLEANUP_wget@
	touch $@

if TARGETRULESET_FLASH
flash-wget: $(flashprefix)/root/bin/wget

$(flashprefix)/root/bin/wget: wget | $(flashprefix)/root
	rm -f $(flashprefix)/root/bin/wget
	@$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/wget $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

endif

#ncftp
$(DEPDIR)/ncftp: bootstrap @DEPENDS_ncftp@
	@PREPARE_ncftp@
	cd @DIR_ncftp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) clean all LD=$(target)-ld && \
		@INSTALL_ncftp@
	@CLEANUP_ncftp@
	touch $@


if TARGETRULESET_FLASH

flash-ncftp: $(flashprefix)/root/bin/ncftp

$(flashprefix)/root/bin/ncftp: ncftp | $(flashprefix)/root
	@$(INSTALL) -d $(flashprefix)/root/sbin
	@for i in ncftp ncftpbatch ncftpget ncftpls ncftpput ncftpspooler; do \
	$(INSTALL) $(targetprefix)/bin/$$i $(flashprefix)/root/bin; done;
	@FLASHROOTDIR_MODIFIED@

endif

#screen
$(DEPDIR)/screen: bootstrap @DEPENDS_screen@
	@PREPARE_screen@
	cd @DIR_screen@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_screen@
	@CLEANUP_screen@
	touch $@

if TARGETRULESET_FLASH
flash-screen: $(flashprefix)/root/bin/screen

$(flashprefix)/root/bin/screen: screen | $(flashprefix)/root
	rm -f $(flashprefix)/root/bin/screen
	@$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/screen $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

endif

#lzma_utils
$(DEPDIR)/lzma_utils: bootstrap @DEPENDS_lzma_utils@
	@PREPARE_lzma_utils@
	cd @DIR_lzma_utils@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=&& \
		$(MAKE) all && \
		@INSTALL_lzma_utils@
	@CLEANUP_lzma_utils@
	touch $@

if TARGETRULESET_FLASH
flash-lzma_utils: $(flashprefix)/root/bin/lzma

$(flashprefix)/root/bin/lzma: lzma_utils | $(flashprefix)/root
	rm -f $(flashprefix)/root/bin/lzma
	@$(INSTALL) -d $(flashprefix)/root/bin
	@for i in lzdiff lzgrep lzma lzmadec lzmainfo lzmore; do \
	$(INSTALL) $(targetprefix)/bin/$$i $(flashprefix)/root/bin; done;
		@ln -sf lzma $(flashprefix)/root/bin/lzcat
		@ln -sf lzdiff $(flashprefix)/root/bin/lzcmp
		@ln -sf lzgrep $(flashprefix)/root/bin/lzfgrep
		@ln -sf lzgrep $(flashprefix)/root/bin/lzegrep
		@ln -sf lzmore $(flashprefix)/root/bin/lzless
	@FLASHROOTDIR_MODIFIED@

endif

