#######################
#
# bluetooth
#

$(DEPDIR)/bluez_hcidump: bootstrap bluez_libs @DEPENDS_bluez_hcidump@
	@PREPARE_bluez_hcidump@
	cd @DIR_bluez_hcidump@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--with-bluez-libs=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_bluez_hcidump@
	@CLEANUP_bluez_hcidump@
	touch $@

$(DEPDIR)/bluez_libs: bootstrap @DEPENDS_bluez_libs@
	@PREPARE_bluez_libs@
	cd @DIR_bluez_libs@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_bluez_libs@
	@CLEANUP_bluez_libs@
	touch $@

$(DEPDIR)/bluez_pan: bootstrap bluez_sdp @DEPENDS_bluez_pan@
	@PREPARE_bluez_pan@
	cd @DIR_bluez_pan@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-bluez-includes=$(targetprefix)/include \
			--with-bluez-libs=$(targetprefix)/lib \
			--with-sdp-includes=$(targetprefix)/include \
			--with-sdp-libs=$(targetprefix)/lib && \
		$(MAKE) all && \
		@INSTALL_bluez_pan@
	@CLEANUP_bluez_pan@
	touch $@

$(DEPDIR)/bluez_sdp: bootstrap bluez_libs @DEPENDS_bluez_sdp@
	@PREPARE_bluez_sdp@
	cd @DIR_bluez_sdp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-bluez-includes=$(targetprefix)/include \
			--with-bluez-libs=$(targetprefix)/lib && \
		$(MAKE) all && \
		@INSTALL_bluez_sdp@
	@CLEANUP_bluez_sdp@
	touch $@

$(DEPDIR)/bluez_utils: bootstrap bluez_libs @DEPENDS_bluez_utils@
	@PREPARE_bluez_utils@
	cd @DIR_bluez_utils@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-bluez-includes=$(targetprefix)/include \
			--with-bluez-libs=$(targetprefix)/lib && \
		$(MAKE) all && \
		@INSTALL_bluez_utils@
	@CLEANUP_bluez_utils@
	touch $@
