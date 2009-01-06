#######################
#
# java stuff
#

java: kaffeh kaffe

# for x86
$(DEPDIR)/kaffeh: bootstrap @DEPENDS_kaffeh@
	@PREPARE_kaffeh@
	cd @DIR_kaffeh@ && \
		./configure \
			--host=$(build) \
			--prefix=$(hostprefix) \
			--disable-dependency-tracking \
			--without-x \
			--without-suncompat \
			--disable-gcj && \
		$(MAKE) all && \
		@INSTALL_kaffeh@
	@CLEANUP_kaffeh@
	touch $@

# for ppc
$(DEPDIR)/kaffe: bootstrap kaffeh libffi @DEPENDS_kaffe@
	@PREPARE_kaffe@
	cd @DIR_kaffe@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-dependency-tracking \
			--without-x \
			--without-suncompat \
			--disable-gcj && \
		$(MAKE) all && \
		@INSTALL_kaffe@
	@CLEANUP_kaffe@
	touch $@
