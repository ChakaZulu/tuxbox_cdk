AC_INIT(Makefile.am)
AC_PREREQ(2.50)
AM_INIT_AUTOMAKE(tuxbox-cdk, 0.0.1)
AM_MAINTAINER_MODE

AC_PROG_CC

AC_CANONICAL_BUILD
AC_SUBST(build)
if test "$target_alias" = "" ; then
	target_alias="powerpc-tuxbox-linux-gnu"
fi
AC_CANONICAL_TARGET
AC_SUBST(target)

AC_ARG_WITH(hostruleset,
	[  --with-hostruleset=NAME host ruleset [[standard,cygwin]]],
	[hostruleset="$withval"],[hostruleset="standard"])

if test "$host_os" = "cygwin" -a "$hostruleset" = "standard"; then
	AC_MSG_WARN([overriding standard ruleset])
	hostruleset="cygwin"
fi

if test "$hostruleset" = "standard"; then
	MAKERULESETFILE=""
elif test "$hostruleset" = "cygwin"; then
	MAKERULESETFILE="-cygwin"
else
	AC_MSG_ERROR([invalid hostruleset "$hostruleset", choose on from standard or cygwin]);
fi

AM_CONDITIONAL(HOSTRULESET_CYGWIN,test "$hostruleset" = "cygwin")

AC_ARG_WITH(targetruleset,
	[  --with-targetruleset=NAME target ruleset [[standard,flash]]],
	[targetruleset="$withval"],[targetruleset="standard"])

if test "$targetruleset" = "standard"; then
	INSTALLRULESETFILE=""
elif test "$targetruleset" = "flash"; then
	INSTALLRULESETFILE="-flash"
else
	AC_MSG_ERROR([invalid targetruleset "$targetruleset", choose on from standard or flash]);
fi

if test -z "$CFLAGS" ; then
	CFLAGS="-O2"
fi

if test -z "$TARGET_CFLAGS" -o -z "$TARGET_CXXFLAGS"; then
	if test "$targetruleset" = "standard"; then
		TARGET_CFLAGS="-O3 -mcpu=823 -msoft-float -mmultiple -mstring -meabi -g -pipe"
		TARGET_LDFLAGS=""
	elif test "$targetruleset" = "flash"; then
		TARGET_CFLAGS="-Os -mcpu=823 -msoft-float -mmultiple -mstring -meabi -pipe"
		TARGET_LDFLAGS="-s"
	fi
	TARGET_CXXFLAGS="$TARGET_CFLAGS"
fi

AC_SUBST(CFLAGS)
AC_SUBST(TARGET_CFLAGS)
AC_SUBST(TARGET_CXXFLAGS)
AC_SUBST(TARGET_LDFLAGS)

AM_CONDITIONAL(TARGETRULESET_STANDARD,test "$targetruleset" = "standard")
AM_CONDITIONAL(TARGETRULESET_FLASH,test "$targetruleset" = "flash")

AC_PREFIX_DEFAULT(/dbox2)

if test "$prefix" = "NONE"; then
	prefix=/dbox2
fi

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

AC_ARG_WITH(hostapsdir,
	[  --with-hostappsdir=DIR  hostapps dir from cvs [[[CVS/]hostapps]]],
	[hostappsdir="$with_driverdir"],[hostappsdir="NONE"])

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

AC_MSG_CHECKING([for apps directory])
if test ! -f "$appsdir/dvb/zapit/configure.ac" ; then
	appsdir=no
	AC_MSG_RESULT([no])
else
	AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for boot directory])
if test ! -f "$bootdir/ppcboot/Makefile" ; then
	bootdir=no
	AC_MSG_RESULT([no])
else
	AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for driver directory])
if test ! -f "$driverdir/Makefile" ; then
	driverdir=no
	AC_MSG_RESULT([no])
else
	AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for hostapps directory])
if test ! -f "$hostappsdir/configure.ac" ; then
	hostappsdir=no
	AC_MSG_RESULT([no])
else
	AC_MSG_RESULT([yes])
fi

AC_SUBST(appsdir)
AC_SUBST(bootdir)
AC_SUBST(driverdir)
AC_SUBST(hostappsdir)

if test "$targetruleset" = "flash"; then
	AC_PATH_PROG(MKLIBS,mklibs,no)
	if test "$MKLIBS" = "no"; then
		AC_MSG_WARN(can't build libs)
		MKLIBS=/bin/false
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
KERNELVERSION=`${srcdir}/rules-make.pl ${srcdir}/rules-make${MAKERULESETFILE} linux version`
AC_SUBST(KERNELVERSION)
TUXBOX_RULES_MAKE(linux)
TUXBOX_RULES_MAKE_EXDIR(binutils)
TUXBOX_RULES_MAKE_EXDIR(bootstrap_gcc)
TUXBOX_RULES_MAKE_EXDIR(glibc)
TUXBOX_RULES_MAKE_EXDIR(gcc)
TUXBOX_RULES_MAKE(uclibc)

#
# root
#
TUXBOX_RULES_MAKE(busybox)
TUXBOX_RULES_MAKE(ftpd)
TUXBOX_RULES_MAKE(ifupdown)
TUXBOX_RULES_MAKE(inetd)
TUXBOX_RULES_MAKE(modutils)
TUXBOX_RULES_MAKE(netkit_telnet)
TUXBOX_RULES_MAKE(portmap)
TUXBOX_RULES_MAKE(procps)
TUXBOX_RULES_MAKE(watchdog)

#
# contrib libs
#
TUXBOX_RULES_MAKE(libboost)
TUXBOX_RULES_MAKE(libcommoncplusplus)
TUXBOX_RULES_MAKE(libcrypto)
TUXBOX_RULES_MAKE(libcurl)
TUXBOX_RULES_MAKE(libdirectfb)
TUXBOX_RULES_MAKE(libdirectfbpp)
TUXBOX_RULES_MAKE(libdvbpsi)
TUXBOX_RULES_MAKE(libffi)
TUXBOX_RULES_MAKE(libfreetype)
TUXBOX_RULES_MAKE(libmad)
TUXBOX_RULES_MAKE(libncurses)
TUXBOX_RULES_MAKE(libjpeg)
TUXBOX_RULES_MAKE(libpcap)
TUXBOX_RULES_MAKE(libpng)
TUXBOX_RULES_MAKE(libpopt)
TUXBOX_RULES_MAKE(libreadline)
TUXBOX_RULES_MAKE(libsdl)
TUXBOX_RULES_MAKE(libsigc)
TUXBOX_RULES_MAKE(libxml2)
TUXBOX_RULES_MAKE(libz)

#
# contrib apps
#
TUXBOX_RULES_MAKE(console_data)
TUXBOX_RULES_MAKE(console_tools)
TUXBOX_RULES_MAKE(directfb_examples)
TUXBOX_RULES_MAKE(fbset)
TUXBOX_RULES_MAKE(lirc)
TUXBOX_RULES_MAKE(lsof)
TUXBOX_RULES_MAKE(pump)
TUXBOX_RULES_MAKE(ssh)
TUXBOX_RULES_MAKE(tcpdump)
TUXBOX_RULES_MAKE(xrc)
TUXBOX_RULES_MAKE(thttpd)

#
# msttf
#
TUXBOX_RULES_MAKE(cabextract)
TUXBOX_RULES_MAKE(msttf)

#
# additional
#
TUXBOX_RULES_MAKE(gdb)
TUXBOX_RULES_MAKE(ksymoops)
TUXBOX_RULES_MAKE(ltrace)
TUXBOX_RULES_MAKE(strace)
TUXBOX_RULES_MAKE(nano)

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

#
# dvb apps
#
TUXBOX_RULES_MAKE(dvbdate)
TUXBOX_RULES_MAKE(dvbstream)
TUXBOX_RULES_MAKE(dvbtext)
TUXBOX_RULES_MAKE(dvbtune)
TUXBOX_RULES_MAKE(vls)

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
AC_MSG_RESULT([
Summary:
Hostruleset:	$hostruleset
Targetruleset:	$targetruleset
Targetprefix:	$targetprefix
Hostprefix:	$hostprefix
Bootprefix:	$bootprefix
Buildprefix:	$buildprefix
Appsdir:	$appsdir
Bootdir:	$bootdir
Driverdir:	$driverdir
Hostappsdir:	$hostappsdir
])

AC_OUTPUT([
Makefile
etc/Makefile
etc/init.d/Makefile
etc/fstab
etc/modules.conf
etc/init.d/rcS
etc/init.d/start_sshd
])
