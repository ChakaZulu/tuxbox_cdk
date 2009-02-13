#######################
#
#   pulseaudio
#

$(DEPDIR)/liboil: bootstrap @DEPENDS_liboil@
	@PREPARE_liboil@
	cd @DIR_liboil@ && \
		$(BUILDENV) \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--disable-glib \
			--prefix= && \
		$(MAKE) && \
		@INSTALL_liboil@
	@CLEANUP_liboil@
	touch $@

$(DEPDIR)/libsndfile: bootstrap @DEPENDS_libsndfile@
	@PREPARE_libsndfile@
	cd @DIR_libsndfile@ && \
		$(BUILDENV) \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-sqlite \
			--disable-flac \
			--disable-alsa && \
		$(MAKE) && \
		@INSTALL_libsndfile@
	@CLEANUP_libsndfile@
	touch $@

$(DEPDIR)/libsamplerate: bootstrap libsndfile @DEPENDS_libsamplerate@
	@PREPARE_libsamplerate@
	cd @DIR_libsamplerate@ && \
		$(BUILDENV) \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		sed 's#\(\#define CPU_IS_BIG_ENDIAN\).*#\1 1#g' src/config.h > src/config.h.new && \
		mv src/config.h.new src/config.h && \
		$(MAKE) && \
		@INSTALL_libsamplerate@
	@CLEANUP_libsamplerate@
	touch $@

$(DEPDIR)/libogg: bootstrap @DEPENDS_libogg@
	@PREPARE_libogg@
	cd @DIR_libogg@ && \
		$(BUILDENV) \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) && \
		@INSTALL_libogg@
	@CLEANUP_libogg@
	touch $@

$(DEPDIR)/speex: bootstrap libogg @DEPENDS_speex@
	@PREPARE_speex@
	cd @DIR_speex@ && \
		$(BUILDENV) \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--with-ogg=$(targetprefix) \
			--prefix= && \
		$(MAKE) && \
		@INSTALL_speex@
	@CLEANUP_speex@
	touch $@

$(DEPDIR)/libatomic_ops: bootstrap @DEPENDS_libatomic_ops@
	@PREPARE_libatomic_ops@
	cd @DIR_libatomic_ops@ && \
		$(BUILDENV) \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) && \
		@INSTALL_libatomic_ops@
	@CLEANUP_libatomic_ops@
	touch $@
