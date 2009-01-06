# This file contains different cleaning targets. They try to be, at least
# in spirit, compatible with the GNU Makefiles standards.

# Note: automake defines targets clean etc, the Makefile author
# therefore should not. Instead, we define targets like clean-local,
# which are called from automake's clean.


# Delete all marker files in .deps, except those belonging to bootstrap,
# thus forcing unpack-patch-install-delete-targets to be rebuilt.
depsclean:
	$(DEPSCLEANUP)

# Delete all marker files in .deps for ccache-enviroment
ccache-depsclean:
	$(CCACHE_DEPSCLEANUP)

# Delete all marker files in .deps for ide-apps, contrib-apps
ide-apps-depsclean:
	$(IDE_DEPSCLEANUP)
contrib-apps-depsclean:
	$(CONTRIB_DEPSCLEANUP)


if TARGETRULESET_FLASH
mostlyclean-local: flash-clean cdk-clean
else
mostlyclean-local: cdk-clean
endif

# Clean tuxbox source directories
cdk-clean:
	-$(MAKE) -C linux clean
	-$(MAKE) -C $(driverdir) KERNEL_LOCATION=$(buildprefix)/linux \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix) clean
	-$(MAKE) -C $(appsdir)/tuxbox/neutrino clean
	-$(MAKE) -C $(appsdir)/tuxbox/enigma clean
	-$(MAKE) -C $(appsdir)/tuxbox/lcars clean
	-$(MAKE) -C $(appsdir)/tuxbox/radiobox clean
	-$(MAKE) -C $(appsdir)/tuxbox/plugins clean
	-$(MAKE) -C $(appsdir)/tuxbox/tools clean
	-$(MAKE) -C $(appsdir)/tuxbox/lcd clean
	-$(MAKE) -C $(appsdir)/tuxbox/libs clean
	-$(MAKE) -C $(appsdir)/tuxbox/libtuxbox clean
	-$(MAKE) -C $(appsdir)/misc/tools clean
	-$(MAKE) -C $(appsdir)/misc/libs clean
	-$(MAKE) -C $(appsdir)/dvb/tools clean
	-$(MAKE) -C $(appsdir)/dvb/config distclean
	-$(MAKE) -C $(appsdir)/dvb/dvbsnoop clean
	-$(MAKE) -C $(appsdir)/dvb/zapit clean
	-$(MAKE) -C $(hostappsdir) clean
	-$(MAKE) -C root clean
	-rm -rf build

# Clean tuxbox source directories. Clean up in cdkroot as much as the
# uninstall facilities of the components allow.
clean-local: mostlyclean-local depsclean
	-$(MAKE) -C $(appsdir)/tuxbox/neutrino uninstall
	-$(MAKE) -C $(appsdir)/tuxbox/enigma uninstall
	-$(MAKE) -C $(appsdir)/tuxbox/lcars uninstall
	-$(MAKE) -C $(appsdir)/tuxbox/radiobox uninstall
	-$(MAKE) -C $(appsdir)/tuxbox/plugins uninstall
	-$(MAKE) -C $(appsdir)/tuxbox/tools uninstall
	-$(MAKE) -C $(appsdir)/tuxbox/lcd uninstall
	-$(MAKE) -C $(appsdir)/tuxbox/libs uninstall
	-$(MAKE) -C $(appsdir)/tuxbox/libtuxbox uninstall
	-$(MAKE) -C $(appsdir)/misc/tools uninstall
	-$(MAKE) -C $(appsdir)/misc/libs uninstall
	-$(MAKE) -C $(appsdir)/dvb/tools uninstall
	-$(MAKE) -C $(appsdir)/dvb/config uninstall
	-$(MAKE) -C $(appsdir)/dvb/dvbsnoop uninstall
	-$(MAKE) -C $(appsdir)/dvb/zapit uninstall
	-$(MAKE) -C $(hostappsdir) uninstall
	-rm -f $(bootprefix)/dboxflasher
	-rm -f $(bootprefix)/dboxflasher-fb
	-rm -f $(bootprefix)/dboxflasher-lcd
	-rm -f $(bootprefix)/u-boot
	-rm -f $(bootprefix)/u-boot-yadd
	-rm -f $(bootprefix)/kernel-cdk
	-rm -rf $(serversupport)

# Be brutal...just nuke it!
distclean-local:
	-$(MAKE) -C root distclean
	-$(MAKE) -C $(appsdir) distclean
	-$(MAKE) -C $(appsdir)/dvb/configtools distclean
	-$(MAKE) -C $(appsdir)/dvb/dvbsnoop distclean
	-$(MAKE) -C $(appsdir)/dvb/dvb/libdvb++ distclean
	-$(MAKE) -C $(appsdir)/dvb/dvb/libdvbsi++ distclean
	-$(MAKE) -C $(appsdir)/dvb/tools distclean
	-$(MAKE) -C $(appsdir)/dvb/zapit distclean
	-$(MAKE) -C $(appsdir)/tuxbox/enigma distclean
	-$(MAKE) -C $(appsdir)/tuxbox/funstuff distclean
	-$(MAKE) -C $(appsdir)/tuxbox/lcars distclean
	-$(MAKE) -C $(appsdir)/tuxbox/radiobox distclean
	-$(MAKE) -C $(appsdir)/tuxbox/lcd distclean
	-$(MAKE) -C $(appsdir)/tuxbox/libs distclean
	-$(MAKE) -C $(appsdir)/tuxbox/libtuxbox distclean
	-$(MAKE) -C $(appsdir)/tuxbox/neutrino distclean
	-$(MAKE) -C $(appsdir)/tuxbox/tools distclean
	-$(MAKE) -C $(appsdir)/misc/libs distclean
	-$(MAKE) -C $(appsdir)/misc/tools distclean
	-$(MAKE) -C $(hostappsdir) distclean
	-$(MAKE) -C $(appsdir)/tuxbox/tools/hotplug distclean
	-$(MAKE) -C $(driverdir) distclean KERNEL_LOCATION=$(buildprefix)/linux
	-rm -f Makefile-archive
	-rm -f rules-downcheck.pl
	-rm -f linux
	-rm -rf $(DEPDIR)
	-rm -rf $(targetprefix)
	-rm -rf $(hostprefix)
	-rm -f $(bootprefix)/dboxflasher
	-rm -f $(bootprefix)/dboxflasher-fb
	-rm -f $(bootprefix)/dboxflasher-lcd
	-rm -f $(bootprefix)/u-boot
	-rm -f $(bootprefix)/u-boot-yadd
	-rm -f $(bootprefix)/kernel-cdk
	-rm -rf $(serversupport)
if TARGETRULESET_FLASH
	-rm -rf $(flashprefix)
endif
	-@CLEANUP@


if TARGETRULESET_FLASH
################################################################
# flash-clean deletes everything created with the flash-* commands
# flash-semiclean leaves the flfs-images and the root-$filesystem dirs.
# (This is sensible, while these files seldomly change, and take rather
# long to build.)

# flash-semiclean is "homemade",
# flash-clean and flash-mostlyclean have semantics like in the GNU
# Makefile standards.

flash-semiclean:
	rm -f $(flashprefix)/*.cramfs $(flashprefix)/*.squashfs \
	$(flashprefix)/*.jffs2 $(flashprefix)/.*-flfs \
	$(flashprefix)/*.list
	rm -rf $(flashprefix)/root
	rm -rf $(flashprefix)/root-neutrino*
	rm -rf $(flashprefix)/root-radiobox*
	rm -rf $(flashprefix)/root-enigma*
	rm -rf $(flashprefix)/var*

flash-mostlyclean: flash-semiclean
	rm -rf $(flashprefix)/root-*
	rm -f $(flashprefix)/*.flfs*x

flash-clean: flash-mostlyclean
	rm -f $(flashprefix)/*.img*
endif ## TARGETRULESET_FLASH

.PHONY: depsclean mostlyclean-local cdk-clean distclean-local flash-semiclean \
flash-mostlyclean flash-clean
