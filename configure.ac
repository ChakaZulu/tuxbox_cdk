AC_INIT(Makefile.am)
AM_INIT_AUTOMAKE(tuxbox-cdk, 0.0.1)

AC_ARG_WITH(target,
	[  --with-target=TARGET    target for compilation [[dbox2,dbox2flash]]],
	[TARGET="$with_target"],[TARGET="dbox2"])

if test "$TARGET" = "dbox2"; then
	TARGET_CFLAGS="-O2 -mcpu=823"
	TARGET_CXXFLAGS="-O2 -mcpu=823"
	TARGET_LDFLAGS="-s"
elif test "$TARGET" = "dbox2flash"; then
	TARGET_CFLAGS="-Os -mcpu=823"
	TARGET_CXXFLAGS="-Os -mcpu=823"
	TARGET_LDFLAGS="-s"
else
	AC_MSG_ERROR([invalid target "$TARGET", choose on from dbox2,dbox2flash]);
fi

AC_SUBST(TARGET)
AC_SUBST(TARGET_CFLAGS)
AC_SUBST(TARGET_CXXFLAGS)
AC_SUBST(TARGET_LDFLAGS)

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

buildprefix=`pwd`
AC_SUBST(targetprefix)
AC_SUBST(hostprefix)
AC_SUBST(buildprefix)

AC_ARG_WITH(cvs,
	[  --with-cvs=DIR          where to find the cvs],
	[cvs="$with_cvs"],[cvs="NONE"])

AC_ARG_WITH(appsdir,
	[  --with-appsdir=DIR      apps dir from cvs [[[CVS/]apps/]]],
	[appsdir="$with_appsdir"],[appsdir="NONE"])

AC_ARG_WITH(bootdir,
	[  --with-bootdir=DIR      boot dir from cvs [[[CVS/]boot/]]],
	[bootdir="$with_bootdir"],[bootdir="NONE"])

AC_ARG_WITH(driverdir,
	[  --with-driverdir=DIR    driver dir from cvs [[[CVS/]driver]]],
	[driverdir="$with_driverdir"],[driverdir="NONE"])

if test "$cvs" = "NONE"; then
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

AC_ARG_WITH(ruleset,
	[  --with-ruleset=NAME     ruleset [[cygwin]]],
	[RULESET="$with_ruleset"],[RULESET="NONE"])

AC_CANONICAL_HOST

if test "$host_os" = "cygwin" -a "$RULESET" == "NONE"; then
	AC_MSG_WARN([overriding standard ruleset])
	RULESET="cygwin"
fi

if test "$RULESET" = "cygwin"; then
	RULESETFILE="-cygwin"
elif test "$RULESET" = "NONE"; then
	RULESETFILE=""
else
	AC_MSG_ERROR([invalid ruleset "$RULESET", choose on from cygwin]);
fi

AC_SUBST(BUILD,[$host])
AC_SUBST(RULESET)

#
# core
#
KERNELVERSION=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESETFILE} linux version`
AC_SUBST(KERNELVERSION)
DEPENDS_linuxdir=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESETFILE} linux depend`
AC_SUBST(DEPENDS_linuxdir)
PREPARE_linuxdir=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESETFILE} linux prepare`
AC_SUBST(PREPARE_linuxdir)
TUXBOX_RULES_MAKE_EXDIR(binutils)
TUXBOX_RULES_MAKE_EXDIR(bootstrap_gcc)
TUXBOX_RULES_MAKE_EXDIR(glibc)
TUXBOX_RULES_MAKE_EXDIR(gcc)
  
#
# minimal root
#
TUXBOX_RULES_MAKE(busybox)

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

AC_PROG_CC

AC_MSG_RESULT()
AC_MSG_RESULT(Summary:)
AC_MSG_RESULT([Target:       $TARGET])
AC_MSG_RESULT([Prefix:       $prefix])
AC_MSG_RESULT([Targetprefix: $targetprefix])
AC_MSG_RESULT([Hostprefix:   $hostprefix])
AC_MSG_RESULT([Buildprefix:  $buildprefix])
if test "$cvs" != "NONE"; then
AC_MSG_RESULT([CVS:          $cvs])
fi
AC_MSG_RESULT([Appsdir:      $appsdir])
AC_MSG_RESULT([Bootdir:      $bootdir])
AC_MSG_RESULT([Driverdir:    $driverdir])
AC_MSG_RESULT([Ruleset:      $RULESET])
AC_MSG_RESULT()

AC_OUTPUT([
Makefile
])
