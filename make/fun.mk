#######################
#
#   fun stuff
#

fun: gnuboy scummvm sdldoom

# does not build with kernel 2.6 headers yet
$(DEPDIR)/gnuboy: bootstrap @DEPENDS_gnuboy@
	@PREPARE_gnuboy@
	cd @DIR_gnuboy@ && \
		autoconf && \
		$(BUILDENV) \
		CPPFLAGS="-I$(driverdir)/include" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_gnuboy@
	@CLEANUP_gnuboy@
	touch $@

$(DEPDIR)/scummvm: bootstrap libreadline libsdl libmad @DEPENDS_scummvm@
	@PREPARE_scummvm@
	cd @DIR_scummvm@ && \
		$(MAKE) \
			$(BUILDENV) \
			AR='$(target)-ar cru' \
			DEFINES="-DUNIX" && \
		@INSTALL_scummvm@
	@CLEANUP_scummvm@
	touch $@

$(DEPDIR)/sdldoom: bootstrap libsdl @DEPENDS_sdldoom@
	@PREPARE_sdldoom@
	cd @DIR_sdldoom@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_sdldoom@
	@CLEANUP_sdldoom@
	touch $@

$(DEPDIR)/tinygl: bootstrap @DEPENDS_tinygl@
	@PREPARE_tinygl@
	cp -p $(appsdir)/tuxbox/tools/graphics/fbgl.c @DIR_tinygl@/examples
	cd @DIR_tinygl@ && \
		$(MAKE) all
		for prog in gears mech spin texobj; do \
			 $(INSTALL) @DIR_tinygl@/examples/$$prog $(targetprefix)/bin; \
		done
		$(INSTALL) -m 644 @DIR_tinygl@/lib/libTinyGL.a $(targetprefix)/lib
	@CLEANUP_tinygl@
	touch $@
