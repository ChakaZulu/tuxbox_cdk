## Makefile for Tuxbox

J := 1

# Define high-level and yadd targets
include make/high-level-yadd.mk

# Set up some default values (used only by serversetup).
include make/defaultvalues.mk

# Set up the build environment
include make/buildenv.mk

# Set up the cross compilation enironment, including linux kernel
# source and directory structure
include make/bootstrap.mk

# Target for building and install own independ ccache for tuxbox-cdk
include make/ccache.mk

# The automounter (optional)
include make/automount.mk

# NFS server
include make/nfsserver.mk

# Samba server
include make/sambaserver.mk

# The busybox (implements most standard Unix commands, like ls,...)
include make/busybox.mk

# Populate the etc directory in YADD
include make/etc.mk

# The ftpd
include make/ftpd.mk

# Set up default locale
include make/defaultlocale.mk

# Some core tools (important and less important)
include make/rootutils.mk

# A number of libraries, some of which necessary for neutrino or enigma
include make/contrib-libs.mk

# Some non-GUI applications, none of which are essential
include make/contrib-apps.mk

# Some IDE/HDD tools and applications if IDE-support enabled
include make/ide-apps.mk

# Tools (debugger etc) for the Tuxbox developer
include make/development-tools.mk

# The kaffe java-implementation (nonessential, presently does not build) 
include make/java-stuff.mk

# Gaming platforms (gnuboy scummvm sdldoom)
include make/fun.mk

# Nonessential DVB application 
include make/dvb-apps.mk

# Bluetooth (nonessential)
include make/bluetooth.mk

# Database
include make/database.mk

# FUSE and djmount for uPnP support (non-essential)
include make/upnp.mk

if !BOXTYPE_IPBOX
# The u-boot boot loader
include make/u-boot.mk
endif

# Build kernel and its drivers
include make/linuxkernel.mk

# Install dvb configuration files (cables.xml & satellites.xml)
include make/dvb-config.mk

# dvbsnoop is a tool for analyzing dvb streams (non-essential)
include make/dvbsnoop.mk

# A nonessential library
include make/libdvbsi++.mk

# A nonessential library
include make/libdvb++.mk

# The zapit daemon
include make/zapit.mk

# More dvb tools, of which only streampes is installed per default
include make/dvb_tools.mk

# More misc libs, mostly nonessential
include make/misc_libs.mk

# Misc tools, not essential
include make/misc_tools.mk

# Enigma GUI
include make/enigma.mk

# nonessential entertainment, like "screensavers" for the lcd display
include make/funstuff.mk

# The LCARS GUI
include make/lcars.mk

# LCD tools
include make/lcd.mk

# Essential, and some less essential, libraries
include make/tuxbox_libs.mk

# A small, but absolutely essential library
include make/libtuxbox.mk

# The Neutrino GUI
include make/neutrino.mk

# Radiobox GUI (experimental)
include make/radiobox.mk

# Plugins
include make/plugins.mk

# Some small command line tools, several of which are essential
include make/tuxbox_tools.mk

# Application that run on the build host
include make/hostapps.mk

# Generate some support files for a YADD- or flashing-server
include make/serversupport.mk

# Optionally install ucodes in the image
include make/ucodes.mk

# Generate a /.version file in the image
include make/version.mk

if TARGETRULESET_FLASH
# High-level flash targets are:

# flash-[neutrino,enigma,all]-[cramfs,squashfs,jffs2,all]-[1x,2x,all]
# Expand all flash targets containg the word "all"
include make/flash-expand-targets.mk

# Create complete images ("without BN bootloader")
include make/fullimages.mk

# Create images of the root and var file systems
include make/partition-images.mk

# Create root and var filesystems, ready for image creation
include make/flashable-dirs.mk

# Strip libraries of symbols not needed.
include make/reduce-libs.mk

if !BOXTYPE_IPBOX
# Create the root file systems for jffs2-only, cramfs, and squashfs
# images (containing kernel but not GUI)
include make/flashroot-fs.mk
endif

# Create the root file system, without kernel and GUI 
include make/flashroot.mk

# The streampes stuff
include make/flash-streampes.mk

# Build distribution lists in neutrino internet update format
include make/distribution-lists.mk

# /etc/update.urls contains URLs for update lists
include make/update.urls.mk

if BOXTYPE_IPBOX
# build IPBox images
include make/ipbox.mk
endif

endif

# Files not to be deleted, even though they are intermediate products
include make/precious.mk

# "Phony" make targets
include make/phony.mk

# Create the TAGS file
include make/tags.mk

# A number of cleaning targets
include make/cleantargets.mk

# Target for building source distributions (hardly used these days of CVS :-)
include make/disttargets.mk

# Give the user rope to hang himself :-).  (Note: read from the
# generated Makefile during make run, automake or configure does not
# see it.)
-include ./Makefile.local

# add user specific stuff if needed
-include $(customizationsdir)/user.mk

