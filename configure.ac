AC_INIT(Makefile.am)
AM_INIT_AUTOMAKE(tuxbox-cdk, 0.0.1)

AC_ARG_WITH(ruleset,
	[  --with-ruleset=NAME     extra rules for compilation [cygwin]],
	[RULESET="$with_ruleset"],[RULESET="NONE"])

AC_ARG_WITH(target,
	[  --with-target=TARGET    target for compilation [dbox2,dbox2flash]],
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
	AC_MSG_ERROR([invalid target $TARGET, choose on from dbox2,dbox2flash]);
fi

if test "$RULESET" = "cygwin"; then
	RULESET="-cygwin"
elif test "$RULESET" = "NONE"; then
	RULESET=""
else
	AC_MSG_ERROR([invalid ruleset $RULESET, choose on from cygwin]);
fi

AC_SUBST(TARGET_CFLAGS)
AC_SUBST(TARGET_CXXFLAGS)
AC_SUBST(TARGET_LDFLAGS)

AC_PROG_CC
AC_CANONICAL_HOST

BUILD="$host"
AC_SUBST(BUILD)

targetprefix="\${prefix}/target"
hostprefix="\${prefix}/host"
buildprefix=`pwd`
AC_SUBST(targetprefix)
AC_SUBST(hostprefix)
AC_SUBST(buildprefix)

#
# core
#
KERNELVERSION=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} linux version`
AC_SUBST(KERNELVERSION)
DEPENDS_linuxdir=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} linux depend`
AC_SUBST(DEPENDS_linuxdir)
PREPARE_linuxdir=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} linux prepare`
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

AC_OUTPUT([
Makefile
])
