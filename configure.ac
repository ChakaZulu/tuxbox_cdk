AC_INIT([tuxbox-cdk],[0])
AC_PREREQ(2.57a)

AC_CANONICAL_BUILD
AC_SUBST(build)
if test "$target_alias" = "" ; then
	target_alias="powerpc-tuxbox-linux-gnu"
fi
AC_CANONICAL_TARGET
AC_SUBST(target)

AM_INIT_AUTOMAKE([])
AM_MAINTAINER_MODE

AC_PROG_CC

AC_ARG_ENABLE(libcrypto,
	AS_HELP_STRING(--disable-libcrypto,don't build libcrypto to reduce binary size),
	,[enable_libcrypto=yes])
AM_CONDITIONAL(WITH_LIBCRYPTO,test "$enable_libcrypto" = "yes")

AC_ARG_ENABLE(kernel26,
	AS_HELP_STRING(--enable-kernel26,set up the CDK to use the 2.6 kernel (experimental)),
	,[enable_kernel26=no])
AM_CONDITIONAL(KERNEL26,test "$enable_kernel26" = "yes")

AC_ARG_ENABLE(nptl,
	AS_HELP_STRING(--disable-nptl,do not use native posix threads for glibc (only meaningful for kernel 2.6.x, default for 2.4.x)),
	,[
		if test "$enable_kernel26" = "yes"; then 
			enable_nptl=yes
		else
			enable_nptl=no
		fi
	])
if test "$enable_nptl" = "yes"; then
	if test "$enable_kernel26" != "yes"; then
		AC_MSG_ERROR([Option --enable-nptl (native posix threads) is only supported for a 2.6.x kernel])
	fi
	GLIBC_PTHREADS="nptl"
else
	GLIBC_PTHREADS="linuxthreads"
fi
AC_SUBST(GLIBC_PTHREADS)

AC_ARG_WITH(cpu,
	[  --with-cpu=MODEL        cpu model [[823,405]]],
	[CPU_MODEL="$withval"],[CPU_MODEL="823"])
AC_SUBST(CPU_MODEL)

AC_ARG_WITH(hostruleset,
	[  --with-hostruleset=NAME host ruleset [[standard,cygwin]]],
	[HOSTRULESET="$withval"],[HOSTRULESET="NULL"])

if test "$HOSTRULESET" = "NULL"; then
	if test "$host_os" = "cygwin"; then
		HOSTRULESET="cygwin"
	else
		HOSTRULESET="standard"
	fi
fi

if test "$HOSTRULESET" = "standard"; then
	MAKERULESETFILE=""
elif test "$HOSTRULESET" = "cygwin"; then
	MAKERULESETFILE="-cygwin"
else
	AC_MSG_ERROR([invalid hostruleset "$HOSTRULESET", choose on from standard or cygwin]);
fi

################################################################
# ccache
#
AC_ARG_ENABLE(ccache,
	AS_HELP_STRING(--enable-ccache, enable ccache supported compiling ),
	,[enable_ccache=no])
AM_CONDITIONAL(ENABLE_CCACHE,test "$enable_ccache" = "yes")

# optional ccache settings
AC_ARG_WITH(ccachedir,
	[  --with-ccachedir=DIR directory where ccache is installed ],
	[ccachedir="$with_ccachedir"],[ccachedir=$(dirname `which ccache`)])

AC_ARG_WITH(maxcachesize,
	[  --with-maxcachesize=SIZE maximal ccachesize for ccache ],
	[maxcachesize="$with_maxcachesize"],[maxcachesize="0"])

AC_ARG_WITH(maxcachefiles,
	[  --with-maxcachefiles=COUNT maximal count of cachefiles for ccache ],
	[maxcachefiles="$with_maxcachefiles"],[maxcachefiles="0"])

if test "$enable_ccache" = "yes"; then
	if [[ -e $ccachedir/ccache ]]; then
	$ccachedir/ccache -M $maxcachesize
	$ccachedir/ccache -F $maxcachefiles
	ccacheinfo=$($ccachedir/ccache -s)
	else
	enable_ccache="no"
	ccacheinfo="ccache is not installed in $ccachedir, run <make ccache> or install from your distribution"
	fi
fi

AC_SUBST(ccachedir)
AC_SUBST(maxcachesize)
AC_SUBST(maxcachefiles)
AC_SUBST(ccacheinfo)
#
################################################################

AC_SUBST(HOSTRULESET)
AM_CONDITIONAL(HOSTRULESET_STANDARD,test "$HOSTRULESET" = "standard")
AM_CONDITIONAL(HOSTRULESET_CYGWIN,test "$HOSTRULESET" = "cygwin")

AC_ARG_WITH(targetruleset,
	[  --with-targetruleset=NAME target ruleset [[standard,flash]]],
	[TARGETRULESET="$withval"],[TARGETRULESET="standard"])

if test "$TARGETRULESET" = "standard"; then
	INSTALLRULESETFILE=""
elif test "$TARGETRULESET" = "flash"; then
	INSTALLRULESETFILE="-flash"
else
	AC_MSG_ERROR([invalid targetruleset "$TARGETRULESET", choose on from standard or flash]);
fi

AC_SUBST(TARGETRULESET)
AM_CONDITIONAL(TARGETRULESET_STANDARD,test "$TARGETRULESET" = "standard")
AM_CONDITIONAL(TARGETRULESET_FLASH,test "$TARGETRULESET" = "flash")

if test -z "$CFLAGS" ; then
	CFLAGS="-O2"
fi

if test -z "$TARGET_CFLAGS" -o -z "$TARGET_CXXFLAGS"; then
	TARGET_CFLAGS="-pipe"
	if test "$TARGETRULESET" = "standard"; then
		TARGET_CFLAGS="$TARGET_CFLAGS -O2 -g3 -gdwarf-2"
		TARGET_LDFLAGS=""
	elif test "$TARGETRULESET" = "flash"; then
		TARGET_CFLAGS="$TARGET_CFLAGS -Os"
		TARGET_LDFLAGS="-Wl,-O1"
	fi
	TARGET_CXXFLAGS="$TARGET_CFLAGS"
fi

AC_SUBST(CFLAGS)
AC_SUBST(TARGET_CFLAGS)
AC_SUBST(TARGET_CXXFLAGS)
AC_SUBST(TARGET_LDFLAGS)

AC_PREFIX_DEFAULT(/dbox2)

if test "$prefix" = "NONE"; then
	prefix=/dbox2
fi

AC_ARG_ENABLE(ide,
	AS_HELP_STRING(--enable-ide,include ide and ext3 drivers),
	,[enable_ide=no])
AM_CONDITIONAL(ENABLE_IDE,test "$enable_ide" = "yes")

AC_ARG_ENABLE(upnp,
	AS_HELP_STRING(--enable-upnp,include upnp support),
	,[enable_upnp=no])
AM_CONDITIONAL(ENABLE_UPNP,test "$enable_upnp" = "yes")

AC_ARG_ENABLE(flac,
	AS_HELP_STRING(--enable-flac,include Neutrino flac audio decoder with libFLAC),
	,[enable_flac=no])
AM_CONDITIONAL(ENABLE_FLAC,test "$enable_flac" = "yes")

AC_ARG_WITH(targetprefix,
	[  --with-targetprefix=DIR prefix for target files [[PREFIX/cdkroot]]],
	[targetprefix="$with_targetprefix"],[targetprefix="${prefix}/cdkroot"])

AC_ARG_WITH(hostprefix,
	[  --with-hostprefix=DIR   prefix for host files [[PREFIX/cdk]]],
	[hostprefix="$with_hostprefix"],[hostprefix="${prefix}/cdk"])

AC_ARG_WITH(bootprefix,
	[  --with-bootprefix=DIR   prefix for boot files [[PREFIX/tftpboot]]],
	[bootprefix="$with_bootprefix"],[bootprefix="${prefix}/tftpboot"])

AC_ARG_WITH(flashprefix,
	[  --with-flashprefix=DIR  prefix for flash files [[PREFIX/cdkflash]] (only used for flash building)],
	[flashprefix="$with_flashprefix"],[flashprefix="${prefix}/cdkflash"])

buildprefix=`pwd`
AC_SUBST(targetprefix)
AC_SUBST(hostprefix)
AC_SUBST(buildprefix)
AC_SUBST(bootprefix)
AC_SUBST(flashprefix)
flashprefix_ro=${flashprefix}/ro
AC_SUBST(flashprefix_ro)
flashprefix_rw=${flashprefix}/rw
AC_SUBST(flashprefix_rw)

AC_ARG_WITH(cvsdir,
	[  --with-cvsdir=DIR       where to find the cvs],
	[cvsdir="$with_cvsdir"],[cvsdir="NONE"])

AC_ARG_WITH(appsdir,
	[  --with-appsdir=DIR      apps dir from cvs [[[CVS/]apps/]]],
	[appsdir="$with_appsdir"],[appsdir="NONE"])

AC_ARG_WITH(bootdir,
	[  --with-bootdir=DIR      boot dir from cvs [[[CVS/]boot/]]],
	[bootdir="$with_bootdir"],[bootdir="NONE"])

AC_ARG_WITH(driverdir,
	[  --with-driverdir=DIR    driver dir from cvs [[[CVS/]driver]]],
	[driverdir="$with_driverdir"],[driverdir="NONE"])

AC_ARG_WITH(hostappsdir,
	[  --with-hostappsdir=DIR  hostapps dir from cvs [[[CVS/]hostapps]]],
	[hostappsdir="$with_hostappsdir"],[hostappsdir="NONE"])

AC_ARG_WITH(gnuserver,
        [  --with-gnuserver=ADDRESS   the gnu server for gnu-stuff (without ftp://)],
        [gnuserver="$with_gnuserver"],[gnuserver="NONE"])

AC_ARG_WITH(defaultserver,
        [  --with-defaultserver=ADDRESS   the server that is taken if no server is given/works (without http://)],
        [defaultserver="$with_defaultserver"],[defaultserver="NONE"])

if test "$cvsdir" = "NONE"; then
	if test "$appsdir" = "NONE"; then
		appsdir="$buildprefix/apps"
	fi
	if test "$bootdir" = "NONE"; then
		bootdir="$buildprefix/boot"
	fi
	if test "$driverdir" = "NONE"; then
		driverdir="$buildprefix/driver"
	fi
	if test "$hostappsdir" = "NONE"; then
		hostappsdir="$buildprefix/hostapps"
	fi
else
	if test "$appsdir" = "NONE"; then
		appsdir="$cvsdir/apps"
	fi
	if test "$bootdir" = "NONE"; then
		bootdir="$cvsdir/boot"
	fi
	if test "$driverdir" = "NONE"; then
		driverdir="$cvsdir/driver"
	fi
	if test "$hostappsdir" = "NONE"; then
		hostappsdir="$cvsdir/hostapps"
	fi
fi

if test "$gnuserver" = "NONE"; then
	gnuserver="ftp.gwdg.de/pub/misc/gnu/ftp/gnu"
fi

if test "$defaultserver" = "NONE"; then
	defaultserver="tuxbox.berlios.de/pub/tuxbox/cdk/src"
fi

dircheck="ok"
AC_MSG_CHECKING([for apps directory])
if test ! -f "$appsdir/dvb/zapit/configure.ac" ; then
	AC_MSG_WARN([appsdir $appsdir not found])
	appsdir="missing"
	dircheck="fail"
else
	AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for boot directory])
if test ! -d "$bootdir/u-boot-tuxbox" ; then
	AC_MSG_WARN([bootdir $bootdir not found])
	bootdir="missing"
	dircheck="fail"
else
	AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for driver directory])
if test ! -f "$driverdir/Makefile" ; then
	AC_MSG_WARN([driverdir $driverdir not found])
	driverdir="missing"
	dircheck="fail"
else
	AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for hostapps directory])
if test ! -f "$hostappsdir/configure.ac" ; then
	AC_MSG_WARN([hostappsdir $hostappsdir not found])
	hostappsdir="missing"
	dircheck="fail"
else
	AC_MSG_RESULT([yes])
fi

AC_SUBST(appsdir)
AC_SUBST(bootdir)
AC_SUBST(driverdir)
AC_SUBST(hostappsdir)
AC_SUBST(gnuserver)
AC_SUBST(defaultserver)

if test "$TARGETRULESET" = "flash"; then
	AC_PATH_PROG(MKLIBS,mklibs,no)
	if test "$MKLIBS" = "no"; then
		AC_MSG_WARN(using tuxbox mklibs)
		MKLIBS="$hostappsdir/mklibs/mklibs.py"
	fi
	AC_PATH_PROG(FAKEROOT,fakeroot,no)
	if test "$FAKEROOT" = "no"; then
		AC_MSG_WARN(can't build images with uid 0 as non-root)
		FAKEROOT=
	fi
	AC_PATH_PROG(MKCRAMFS,mkcramfs,no)
	if test "$MKCRAMFS" = "no"; then
		AC_MSG_WARN(can't build cramfs)
		MKCRAMFS=/bin/false
	fi
	AC_PATH_PROG(MKJFFS2,mkjffs2,no)
	if test "$MKJFFS2" = "no"; then
		AC_PATH_PROG(MKFSJFFS2,mkfs.jffs2,no)
		if test "$MKFSJFFS2" = "no"; then
			AC_MSG_WARN(can't build jffs2)
			MKJFFS2=/bin/false
		else
			MKJFFS2=$MKFSJFFS2
		fi
	fi
fi

FONTDIR="/share/fonts"
AC_SUBST(FONTDIR)
UCODEDIR="/var/tuxbox/ucodes"
AC_SUBST(UCODEDIR)

CLEANUP="rm -rf"
AC_SUBST(CLEANUP)


#
# core
#
AC_SUBST(KERNELVERSION)
TUXBOX_RULES_MAKE(uboot)

TUXBOX_RULES_MAKE(linux)
TUXBOX_RULES_MAKE(linux24)
if test "$enable_kernel26" = "yes"; then
	KERNELVERSION=$VERSION_linux
else
	KERNELVERSION=$VERSION_linux24
fi

TUXBOX_RULES_MAKE_EXDIR(binutils)
TUXBOX_RULES_MAKE_EXDIR(bootstrap_gcc)
TUXBOX_RULES_MAKE_EXDIR(glibc)
TUXBOX_RULES_MAKE_EXDIR(gcc)
TUXBOX_RULES_MAKE(uclibc)
TUXBOX_RULES_MAKE(libtool)
TUXBOX_RULES_MAKE(squashfs)

#
# root
#
TUXBOX_RULES_MAKE(busybox)
TUXBOX_RULES_MAKE(automount)
TUXBOX_RULES_MAKE(nfs_utils)
TUXBOX_RULES_MAKE(ftpd)
TUXBOX_RULES_MAKE(module_init_tools)
TUXBOX_RULES_MAKE(modutils)
TUXBOX_RULES_MAKE(netkit_telnet)
TUXBOX_RULES_MAKE(portmap)
TUXBOX_RULES_MAKE(procps)
TUXBOX_RULES_MAKE(udev)
TUXBOX_RULES_MAKE(watchdog)
TUXBOX_RULES_MAKE(mrouted)

#
# contrib libs
#
TUXBOX_RULES_MAKE(libboost)
TUXBOX_RULES_MAKE(libcommoncplusplus)
TUXBOX_RULES_MAKE(libcrypto)
TUXBOX_RULES_MAKE(libcurl)
TUXBOX_RULES_MAKE(libdirectfb)
TUXBOX_RULES_MAKE(libdirectfbpp)
TUXBOX_RULES_MAKE(libppdirectfb)
TUXBOX_RULES_MAKE(libdvb)
TUXBOX_RULES_MAKE(libdvbpsi)
TUXBOX_RULES_MAKE(libexpat)
TUXBOX_RULES_MAKE(libffi)
TUXBOX_RULES_MAKE(libfreetype)
TUXBOX_RULES_MAKE(libfribidi)
TUXBOX_RULES_MAKE(libid3tag)
TUXBOX_RULES_MAKE(libgmp)
TUXBOX_RULES_MAKE(libmad)
TUXBOX_RULES_MAKE(libncurses)
TUXBOX_RULES_MAKE(libjpeg)
TUXBOX_RULES_MAKE(libungif)
TUXBOX_RULES_MAKE(libpcap)
TUXBOX_RULES_MAKE(libpng)
TUXBOX_RULES_MAKE(libreadline)
TUXBOX_RULES_MAKE(libsdl)
TUXBOX_RULES_MAKE(libsigc)
TUXBOX_RULES_MAKE(libvorbisidec)
TUXBOX_RULES_MAKE(libxml2)
TUXBOX_RULES_MAKE(libz)
TUXBOX_RULES_MAKE(libglib)
TUXBOX_RULES_MAKE(libiconv)
TUXBOX_RULES_MAKE(libFLAC)

#
# contrib apps
#
TUXBOX_RULES_MAKE(bzip2)
TUXBOX_RULES_MAKE(console_data)
TUXBOX_RULES_MAKE(console_tools)
TUXBOX_RULES_MAKE(directfb_examples)
TUXBOX_RULES_MAKE(fbset)
TUXBOX_RULES_MAKE(lirc)
TUXBOX_RULES_MAKE(lsof)
TUXBOX_RULES_MAKE(ssh)
TUXBOX_RULES_MAKE(tcpdump)
TUXBOX_RULES_MAKE(bonnie)
TUXBOX_RULES_MAKE(vdr)
TUXBOX_RULES_MAKE(lufs)
TUXBOX_RULES_MAKE(dropbear)
TUXBOX_RULES_MAKE(kermit)
TUXBOX_RULES_MAKE(hdparm)
TUXBOX_RULES_MAKE(e2fsprogs)
TUXBOX_RULES_MAKE(dosfstools)
TUXBOX_RULES_MAKE(utillinux)
TUXBOX_RULES_MAKE(parted)
TUXBOX_RULES_MAKE(hddtemp)
TUXBOX_RULES_MAKE(xfsprogs)
TUXBOX_RULES_MAKE(smartmontools)
TUXBOX_RULES_MAKE(samba)
if test "$enable_kernel26" = "no"; then
TUXBOX_RULES_MAKE(fusekernel)
fi
TUXBOX_RULES_MAKE(fuse)
TUXBOX_RULES_MAKE(djmount)
TUXBOX_RULES_MAKE(wget)

#
# ccache
#
TUXBOX_RULES_MAKE(ccache)

#
# msttf
#
TUXBOX_RULES_MAKE(cabextract)
TUXBOX_RULES_MAKE(msttf)

#
# development tools
#
TUXBOX_RULES_MAKE(gdb)
TUXBOX_RULES_MAKE(insight)
TUXBOX_RULES_MAKE(ltrace)
TUXBOX_RULES_MAKE(strace)
TUXBOX_RULES_MAKE(nano)
TUXBOX_RULES_MAKE(mc)
TUXBOX_RULES_MAKE(joe)
TUXBOX_RULES_MAKE(bash)
TUXBOX_RULES_MAKE(python)
TUXBOX_RULES_MAKE(netio)

#
# java
#
TUXBOX_RULES_MAKE(kaffe)
TUXBOX_RULES_MAKE(kaffeh)

#
# fun stuff
#
TUXBOX_RULES_MAKE(gnuboy)
TUXBOX_RULES_MAKE(scummvm)
TUXBOX_RULES_MAKE(sdldoom)
TUXBOX_RULES_MAKE(tinygl)

#
# dvb apps
#
TUXBOX_RULES_MAKE(dvbdate)
TUXBOX_RULES_MAKE(dvbstream)
TUXBOX_RULES_MAKE(dvbtext)
TUXBOX_RULES_MAKE(dvbtune)
TUXBOX_RULES_MAKE(vls)

#
# bluetooth
#
TUXBOX_RULES_MAKE(bluez_hcidump)
TUXBOX_RULES_MAKE(bluez_libs)
TUXBOX_RULES_MAKE(bluez_pan)
TUXBOX_RULES_MAKE(bluez_sdp)
TUXBOX_RULES_MAKE(bluez_utils)

#
# internal
#
AC_SUBST_FILE(ARCHIVE)
ARCHIVE=Makefile-archive
AC_CONFIG_COMMANDS_PRE([
AC_MSG_NOTICE([creating Makefile-archive])
${srcdir}/rules-archive.pl ${srcdir}/rules-archive > Makefile-archive
])

#
# summary
#

if test "$enable_kernel26" = "yes"; then
	used_kernelversion="2.6.x"
else
	used_kernelversion="2.4.x"
fi

AC_MSG_RESULT([
summary:
----------------------------------------
target cpu:            $CPU_MODEL
kernel:                $used_kernelversion
glibc-pthreads:        $GLIBC_PTHREADS
host rule set:         $HOSTRULESET
target rule set:       $TARGETRULESET
target prefix:         $targetprefix
host prefix:           $hostprefix
boot prefix:           $bootprefix
build prefix:          $buildprefix
target apps directory: $appsdir
boot directory:        $bootdir
driver directory:      $driverdir
host apps directory:   $hostappsdir
GNU server:            $gnuserver
default server:        $defaultserver
IDE support:           $enable_ide
UPNP support:          $enable_upnp
FLAC support:          $enable_flac
----------------------------------------
ccache support:		$enable_ccache
ccache installdir:	$ccachedir
$ccacheinfo
----------------------------------------
])

if test "$dircheck" = "fail"; then
AC_MSG_RESULT([
******************************************************************
*                       !!!WARNING!!!                            *
* one or more of your CVS source directories could not be found, *
* (for details see above), did you maybe supply an incorrect     *
*  --with-cvsdir argument to configure?                          *
*                       !!!WARNING!!!                            *
******************************************************************
])
fi

#reset
ccacheinfo=""

AC_CONFIG_FILES([
Makefile
root/Makefile
root/etc/Makefile
root/etc/init.d/Makefile
root/etc/network/Makefile
root/share/Makefile
root/share/udhcpc/Makefile
rules-downcheck.pl
])

AC_CONFIG_COMMANDS([rules-downcheck-chmod],[chmod +x rules-downcheck.pl])

AC_OUTPUT
