AC_INIT(Makefile.am)
AM_INIT_AUTOMAKE(tuxbox-cdk, 0.0.1)

AC_PROG_CC
AC_CANONICAL_HOST

AC_ARG_WITH(hostruleset,
	[  --with-hostruleset=NAME host ruleset [[cygwin]]],
	[hostruleset="$with_hostruleset"],[hostruleset="NONE"])

if test "$host_os" = "cygwin" -a "$hostruleset" == "NONE"; then
	AC_MSG_WARN([overriding standard ruleset])
	hostruleset="cygwin"
fi

if test "$hostruleset" = "cygwin"; then
	MAKERULESETFILE="-cygwin"
elif test "$hostruleset" = "NONE"; then
	MAKERULESETFILE=""
else
	AC_MSG_ERROR([invalid ruleset "$hostruleset", choose on from [[cygwin]]]);
fi

AC_SUBST(BUILD,[$host])

AC_ARG_WITH(targetruleset,
	[  --with-targetrulseset=NAME target ruleset [[flash]]],
	[targetruleset="$with_targetrulseset"],[targetruleset="NONE"])

if test "$targetruleset" = "NONE"; then
	TARGET_CFLAGS="-O2 -mcpu=823"
	TARGET_CXXFLAGS="-O2 -mcpu=823"
	TARGET_LDFLAGS="-s"
	INSTALLRULESFILE=""
	appstarget="dbox2"
elif test "$targetruleset" = "flash"; then
	TARGET_CFLAGS="-Os -mcpu=823"
	TARGET_CXXFLAGS="-Os -mcpu=823"
	TARGET_LDFLAGS="-s"
	INSTALLRULESFILE="-flash"
	APPSTARGET="dbox2flash"
else
AC_MSG_ERROR([invalid ruleset "$targetruleset", choose on from [[flash]]]);
fi

AC_SUBST(TARGET_CFLAGS)
AC_SUBST(TARGET_CXXFLAGS)
AC_SUBST(TARGET_LDFLAGS)
AC_SUBST(APPSTARGET)

AC_PREFIX_DEFAULT(/dbox2)

if test "$prefix" = "NONE"; then
	prefix=/dbox2
fi

AC_ARG_WITH(targetprefix,
	[  --with-targetprefix=DIR prefix for target files [[PREFIX/target]]],
	[targetprefix="$with_targetprefix"],[targetprefix="${prefix}/target"])

AC_ARG_WITH(hostprefix,
	[  --with-hostprefix=DIR   prefix for host files [[PREFIX/host]]],
	[hostprefix="$with_hostprefix"],[hostprefix="${prefix}/host"])

AC_ARG_WITH(bootprefix,
	[  --with-bootprefix=DIR   prefix for boot files [[PREFIX/boot]]],
	[bootprefix="$with_bootprefix"],[bootprefix="${prefix}/boot"])

buildprefix=`pwd`
AC_SUBST(targetprefix)
AC_SUBST(hostprefix)
AC_SUBST(buildprefix)
AC_SUBST(bootprefix)

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
else
	if test "$appsdir" = "NONE"; then
		appsdir="$cvs/apps"
	fi
	if test "$bootdir" = "NONE"; then
		bootdir="$cvs/boot"
	fi
	if test "$driverdir" = "NONE"; then
		driverdir="$cvs/driver"
	fi
fi

AC_SUBST(appsdir)
AC_SUBST(bootdir)
AC_SUBST(driverdir)

#
# core
#
KERNELVERSION=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESETFILE} linux version`
AC_SUBST(KERNELVERSION)
TUXBOX_RULES_MAKE(linux)
TUXBOX_RULES_MAKE_EXDIR(binutils)
TUXBOX_RULES_MAKE_EXDIR(bootstrap_gcc)
TUXBOX_RULES_MAKE_EXDIR(glibc)
TUXBOX_RULES_MAKE_EXDIR(gcc)
  
#
# minimal root
#
TUXBOX_RULES_MAKE(busybox)
TUXBOX_RULES_MAKE(modutils)

#
# contrib libs
#
TUXBOX_RULES_MAKE(libcurl)
TUXBOX_RULES_MAKE(libfreetype)
TUXBOX_RULES_MAKE(libncurses)
TUXBOX_RULES_MAKE(libjpeg)
TUXBOX_RULES_MAKE(libpng)
TUXBOX_RULES_MAKE(libqt)
TUXBOX_RULES_MAKE(libxml2)
TUXBOX_RULES_MAKE(libz)

#
# internal
#
AC_CONFIG_COMMANDS_POST([
AC_MSG_NOTICE([creating Makefile-archive])
${srcdir}/rules-archive.pl ${srcdir}/rules-archive > Makefile-archive
])

#
# summary
#
AC_MSG_RESULT()
AC_MSG_RESULT(Summary:)
AC_MSG_RESULT([Hostruleset:	$hostruleset])
AC_MSG_RESULT([Targetruleset:	$targetruleset])
AC_MSG_RESULT([Prefix:		$prefix])
AC_MSG_RESULT([Targetprefix:	$targetprefix])
AC_MSG_RESULT([Hostprefix:	$hostprefix])
AC_MSG_RESULT([Bootprefix:	$bootprefix])
AC_MSG_RESULT([Buildprefix:	$buildprefix])
AC_MSG_RESULT([CVSdir:		$cvsdir])
AC_MSG_RESULT([Appsdir:	$appsdir])
AC_MSG_RESULT([Bootdir:	$bootdir])
AC_MSG_RESULT([Driverdir:	$driverdir])
AC_MSG_RESULT()

AC_OUTPUT([
Makefile
])
