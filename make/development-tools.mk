#######################
#
#   development tools
#

devel: gdb ltrace strace nano joe
devel_optional: gdb-remote insight bash mc

devel_all: devel devel_optional

$(DEPDIR)/gdb: bootstrap libncurses @DEPENDS_gdb@
	@PREPARE_gdb@
	cd @DIR_gdb@ && \
		$(BUILDENV) \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--nfp \
			--disable-tui \
			--without-tui \
			--disable-sim \
			--without-sim \
			--without-expect \
			--disable-expect \
			--prefix= && \
		$(MAKE) all-gdb && \
		@INSTALL_gdb@
	@CLEANUP_gdb@
	touch $@

if TARGETRULESET_FLASH
flash-gdbserver: $(flashprefix)/root/bin/gdbserver
$(flashprefix)/root/bin/gdbserver: gdb
	$(INSTALL) $(targetprefix)/bin/gdbserver $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/lib/libthread_db-1.0.so $(flashprefix)/root/lib
	@FLASHROOTDIR_MODIFIED@
endif

$(DEPDIR)/gdb-remote: @DEPENDS_gdb@
	@PREPARE_gdb@
	cd @DIR_gdb@ && \
		./configure \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--with-sysroot=$(targetprefix) \
			--prefix=$(hostprefix) && \
		$(MAKE) all-gdb && \
		$(MAKE) install-gdb
	@CLEANUP_gdb@
	touch $@

$(DEPDIR)/valgrind: bootstrap @DEPENDS_valgrind@
	@PREPARE_valgrind@
	cd @DIR_valgrind@ && \
		$(BUILDENV) \
		ac_cv_path_GDB=/bin/gdb \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--enable-only32bit \
			--disable-tls \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_valgrind@
	@CLEANUP_valgrind@
	touch $@

$(DEPDIR)/insight: @DEPENDS_insight@
	@PREPARE_insight@
	cd @DIR_insight@ && \
		CONFIG_SHELL=/bin/bash \
		./configure \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) && \
		$(MAKE) all-gdb && \
		$(MAKE) install-gdb
	@CLEANUP_insight@
	touch $@

$(DEPDIR)/ltrace: bootstrap @DEPENDS_ltrace@
	@PREPARE_ltrace@
if TARGETRULESET_UCLIBC
	ln -s linux-gnu @DIR_ltrace@/sysdeps/linux-uclibc
endif
	cd @DIR_ltrace@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) clean all LD=$(target)-ld && \
		@INSTALL_ltrace@
	@CLEANUP_ltrace@
	touch $@

$(DEPDIR)/strace: bootstrap @DEPENDS_strace@
	@PREPARE_strace@
	cd @DIR_strace@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_strace@
	@CLEANUP_strace@
	touch $@

$(DEPDIR)/nano: bootstrap libncurses @DEPENDS_nano@
	@PREPARE_nano@
	cd @DIR_nano@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=  \
			--includedir=$(targetprefix)/include && \
		$(MAKE) all && \
		@INSTALL_nano@
	@CLEANUP_nano@
	touch $@

$(DEPDIR)/joe: bootstrap libncurses @DEPENDS_joe@ 
	@PREPARE_joe@
	cd @DIR_joe@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=  \
			--includedir=$(targetprefix)/include && \
		$(MAKE) all && \
		@INSTALL_joe@
	@CLEANUP_joe@
	touch $@

$(DEPDIR)/mc: bootstrap libglib libncurses @DEPENDS_mc@
	@PREPARE_mc@
	cd @DIR_mc@ && \
		./autogen.sh && \
		$(BUILDENV) \
		CONFIG_SHELL=/bin/bash \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--without-gpm-mouse \
			--with-screen=ncurses \
			--without-x && \
		$(CC) -o src/man2hlp src/man2hlp.c && \
		$(MAKE) all && \
		@INSTALL_mc@
	@CLEANUP_mc@
	touch $@

$(DEPDIR)/bash: bootstrap @DEPENDS_bash@
	@PREPARE_bash@
	cd @DIR_bash@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= &&\
		$(MAKE) all && \
		@INSTALL_bash@
	@CLEANUP_bash@
	touch $@
