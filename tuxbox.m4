AC_DEFUN([TUXBOX_RULES_MAKE],[
DEPENDS_$1=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} $1 depend`
AC_SUBST(DEPENDS_$1)
PREPARE_$1=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} $1 prepare`
AC_SUBST(PREPARE_$1)
DIR_$1=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} $1 dir`
AC_SUBST(DIR_$1)
CLEANUP_$1="rm -rf `${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} $1 dir`"
AC_SUBST(CLEANUP_$1)
])

AC_DEFUN([TUXBOX_RULES_MAKE_EXDIR],[
DEPENDS_$1=`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} $1 depend`
AC_SUBST(DEPENDS_$1)
PREPARE_$1="`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} $1 prepare` && mkdir build"
AC_SUBST(PREPARE_$1)
DIR_$1="build"
AC_SUBST(DIR_$1)
CONFIGURE_$1="../`${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} $1 dir`/configure"
AC_SUBST(CONFIGURE_$1)
CLEANUP_$1="rm -rf `${srcdir}/rules-make.pl ${srcdir}/rules-make${RULESET} $1 dir` build"
AC_SUBST(CLEANUP_$1)
])

