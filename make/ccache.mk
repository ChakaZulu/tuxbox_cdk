#################################################
#  ccache
#
# You can use ccache for compiling if it is installed on your system or Tuxbox-CDK in ~/cdk/bin.
# With this rule you can install ccache independ from your system. 
# Use <make ccache> for installing in cdk/bin. This own ccache-binary is preferred from configure.
# Isn't ccache installed on your system, you can also install later, but you must configure again.
# Most distributions contain the required packages or
# get the sources from http://samba.org/ftp/ccache

if ENABLE_CCACHE
# tuxbox-cdk ccache install path
CCACHE_TUXBOX_BIN = $(ccachedir)/ccache


# tuxbox-cdk ccache environment dir
CCACHE_BINDIR = $(hostprefix)/ccache-bin


# generate links
CCACHE_LINKS = 	ln -sfv $(ccachedir)/ccache $(CCACHE_BINDIR)/gcc;\
 				ln -sfv $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/g++;\
				ln -sfv $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/$(target)-gcc;\
				ln -sfv $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/$(target)-g++;\
				ln -sfv $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/$(target)-cpp;\
				ln -sfv $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/$(target)-gcc-$(VERSION_gcc) 


# ccache test will show you ccache statistics
CCACHE_TEST =	$(CCACHE_TUXBOX_BIN) -s 


# sets the options for ccache which are configured
CCACHE_SETUP =	test "$(maxcachesize)" != -1 && $(CCACHE_TUXBOX_BIN) -M $(maxcachesize);\
		test "$(maxcachefiles)" != -1 && $(CCACHE_TUXBOX_BIN) -F $(maxcachefiles);\
		true


# create ccache environment
CCACHE_ENV = 	$(INSTALL) -d $(CCACHE_BINDIR) ;\
		$(CCACHE_LINKS) ;\
		$(CCACHE_SETUP)


# use ccache from your host if is installed
if USE_CCACHEHOST
ccache:
	$(CCACHE_ENV) ;\
	$(CCACHE_TEST)
	touch $@

else

# build own tuxbox-cdk ccache
ccache:
$(DEPDIR)/ccache: @DEPENDS_ccache@
		@PREPARE_ccache@
		cd @DIR_ccache@ && \
			./configure \
				--build=$(build) \
				--host=$(build) \
				--prefix= && \
				$(MAKE) all && \
				$(MAKE) install DESTDIR=$(hostprefix)
			rm -rf  $(CCACHE_BINDIR);\
			$(CCACHE_ENV) ;\
			$(CCACHE_TEST) ;\
		rm -rf @DIR_ccache@
		touch $@
endif

endif
