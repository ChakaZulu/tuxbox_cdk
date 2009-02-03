#
# Automatically generated make config: don't edit
#

define(`dooption',`ifelse(`$2',`n', `# $1 is not set', `$1=y')')dnl
ifdef(`yadd',`define(`option',`dooption($1,$2)')',`define(`option',`dooption($1,$3)')')dnl
dnl
#
# Busybox Settings
#

CONFIG_HAVE_DOT_CONFIG=y

#
# General Configuration
#
option(`CONFIG_NITPICK', `n', `n')
option(`CONFIG_DESKTOP', `n', `n')
option(`CONFIG_FEATURE_BUFFERS_USE_MALLOC', `n', `n')
option(`CONFIG_FEATURE_BUFFERS_GO_ON_STACK', `y', `y')
option(`CONFIG_FEATURE_BUFFERS_GO_IN_BSS', `n', `n')
option(`CONFIG_SHOW_USAGE', `n', `n')
option(`CONFIG_FEATURE_VERBOSE_USAGE', `n', `n')
option(`CONFIG_FEATURE_COMPRESS_USAGE', `n', `n')
option(`CONFIG_FEATURE_INSTALLER', `n', `n')
option(`CONFIG_LOCALE_SUPPORT', `n', `n')
option(`CONFIG_GETOPT_LONG', `y', `y')
option(`CONFIG_FEATURE_DEVPTS', `y', `y')
option(`CONFIG_FEATURE_CLEAN_UP', `n', `n')
option(`CONFIG_FEATURE_PIDFILE', `n', `n')
option(`CONFIG_FEATURE_SUID', `y', `n')
option(`CONFIG_FEATURE_SYSLOG', `y', `n')
option(`CONFIG_FEATURE_SUID_CONFIG', `n', `n')
option(`CONFIG_FEATURE_SUID_CONFIG_QUIET', `n', `n')
option(`CONFIG_FEATURE_HAVE_RPC', `y', `y')
option(`CONFIG_SELINUX', `n', `n')
option(`CONFIG_FEATURE_PREFER_APPLETS', `n', `n')
CONFIG_BUSYBOX_EXEC_PATH="/proc/self/exe"
option(`CONFIG_AUTH_IN_VAR_ETC', `n', `y')

#
# Build Options
#
option(`CONFIG_STATIC', `n', `n')
option(`CONFIG_BUILD_LIBBUSYBOX', `n', `n')
option(`CONFIG_FEATURE_FULL_LIBBUSYBOX', `n', `n')
option(`CONFIG_FEATURE_SHARED_BUSYBOX', `n', `n')
option(`CONFIG_LFS', `n', `y')
option(`CONFIG_BUILD_AT_ONCE', `n', `n')

#
# Debugging Options
#
option(`CONFIG_DEBUG', `n', `n')
option(`CONFIG_WERROR', `n', `n')
option(`CONFIG_NO_DEBUG_LIB', `n', `n')
option(`CONFIG_DMALLOC', `n', `n')
option(`CONFIG_EFENCE', `n', `n')
option(`CONFIG_INCLUDE_SUSv2', `y', `y')

#
# Installation Options
#
option(`CONFIG_INSTALL_NO_USR', `y', `y')
option(`CONFIG_INSTALL_APPLET_SYMLINKS', `y', `y')
option(`CONFIG_INSTALL_APPLET_HARDLINKS', `n', `n')
option(`CONFIG_INSTALL_APPLET_DONT', `n', `n')
CONFIG_PREFIX=PREFIX

#
# Busybox Library Tuning
#
CONFIG_PASSWORD_MINLEN=5
CONFIG_MD5_SIZE_VS_SPEED=2
option(`CONFIG_FEATURE_FAST_TOP', `n', `n')
option(`CONFIG_FEATURE_ETC_NETWORKS', `n', `n')
option(`CONFIG_FEATURE_EDITING', `y', `y')
CONFIG_FEATURE_EDITING_MAX_LEN=1024
option(`CONFIG_FEATURE_EDITING_FANCY_KEYS', `n', `n')
option(`CONFIG_FEATURE_EDITING_VI', `n', `n')
CONFIG_FEATURE_EDITING_HISTORY=15
option(`CONFIG_FEATURE_EDITING_SAVEHISTORY', `n', `n')
option(`CONFIG_FEATURE_TAB_COMPLETION', `y', `y')
option(`CONFIG_FEATURE_USERNAME_COMPLETION', `n', `n')
option(`CONFIG_FEATURE_EDITING_FANCY_PROMPT', `n', `y')
option(`CONFIG_MONOTONIC_SYSCALL', `n', `n')
option(`CONFIG_IOCTL_HEX2STR_ERROR', `y', `y')

#
# Applets
#

#
# Archival Utilities
#
option(`CONFIG_AR', `n', `n')
option(`CONFIG_FEATURE_AR_LONG_FILENAMES', `n', `n')
option(`CONFIG_BUNZIP2', `y', `y')
option(`CONFIG_CPIO', `n', `n')
option(`CONFIG_DPKG', `n', `n')
option(`CONFIG_DPKG_DEB', `n', `n')
option(`CONFIG_FEATURE_DPKG_DEB_EXTRACT_ONLY', `n', `n')
option(`CONFIG_GUNZIP', `y', `y')
option(`CONFIG_FEATURE_GUNZIP_UNCOMPRESS', `n', `n')
option(`CONFIG_GZIP', `y', `y')
option(`CONFIG_RPM2CPIO', `n', `n')
option(`CONFIG_RPM', `n', `n')
option(`CONFIG_TAR', `y', `y')
option(`CONFIG_FEATURE_TAR_CREATE', `y', `y')
option(`CONFIG_FEATURE_TAR_BZIP2', `y', `y')
option(`CONFIG_FEATURE_TAR_LZMA', `n', `n')
option(`CONFIG_FEATURE_TAR_FROM', `n', `n')
option(`CONFIG_FEATURE_TAR_GZIP', `y', `y')
option(`CONFIG_FEATURE_TAR_COMPRESS', `n', `n')
option(`CONFIG_FEATURE_TAR_OLDGNU_COMPATIBILITY', `y', `y')
option(`CONFIG_FEATURE_TAR_OLDSUN_COMPATIBILITY', `y', `y')
option(`CONFIG_FEATURE_TAR_GNU_EXTENSIONS', `y', `y')
option(`CONFIG_FEATURE_TAR_LONG_OPTIONS', `n', `n')
option(`CONFIG_UNCOMPRESS', `n', `n')
option(`CONFIG_UNLZMA', `n', `n')
option(`CONFIG_FEATURE_LZMA_FAST', `n', `n')
option(`CONFIG_UNZIP', `n', `n')

#
# Common options for cpio and tar
#
option(`CONFIG_FEATURE_UNARCHIVE_TAPE', `n', `n')
option(`CONFIG_FEATURE_DEB_TAR_GZ', `n', `n')
option(`CONFIG_FEATURE_DEB_TAR_BZ2', `n', `n')
option(`CONFIG_FEATURE_DEB_TAR_LZMA', `n', `n')

#
# Coreutils
#
option(`CONFIG_BASENAME', `y', `y')
option(`CONFIG_CAL', `n', `n')
option(`CONFIG_CAT', `y', `y')
option(`CONFIG_CATV', `y', `y')
option(`CONFIG_CHGRP', `y', `n')
option(`CONFIG_CHMOD', `y', `y')
option(`CONFIG_CHOWN', `y', `n')
option(`CONFIG_CHROOT', `y', `n')
option(`CONFIG_CKSUM', `n', `n')
option(`CONFIG_CMP', `n', `n')
option(`CONFIG_COMM', `n', `n')
option(`CONFIG_CP', `y', `y')
option(`CONFIG_CUT', `y', `y')
option(`CONFIG_DATE', `y', `y')
option(`CONFIG_FEATURE_DATE_ISOFMT', `y', `n')
option(`CONFIG_DD', `y', `y')
option(`CONFIG_FEATURE_DD_SIGNAL_HANDLING', `y', `y')
option(`CONFIG_FEATURE_DD_IBS_OBS', `n', `n')
option(`CONFIG_DF', `y', `y')
option(`CONFIG_DIFF', `n', `n')
option(`CONFIG_FEATURE_DIFF_BINARY', `n', `n')
option(`CONFIG_FEATURE_DIFF_DIR', `n', `n')
option(`CONFIG_FEATURE_DIFF_MINIMAL', `n', `n')
option(`CONFIG_DIRNAME', `y', `n')
option(`CONFIG_DOS2UNIX', `n', `y')
option(`CONFIG_UNIX2DOS', `n', `y')
option(`CONFIG_DU', `y', `y')
option(`CONFIG_FEATURE_DU_DEFAULT_BLOCKSIZE_1K', `n', `y')
option(`CONFIG_ECHO', `y', `y')
option(`CONFIG_FEATURE_FANCY_ECHO', `y', `y')
option(`CONFIG_ENV', `y', `y')
option(`CONFIG_FEATURE_ENV_LONG_OPTIONS', `n', `n')
option(`CONFIG_EXPAND', `n', `n')
option(`CONFIG_FEATURE_EXPAND_LONG_OPTIONS', `n', `n')
option(`CONFIG_EXPR', `y', `y')
option(`CONFIG_EXPR_MATH_SUPPORT_64', `n', `n')
option(`CONFIG_FALSE', `y', `y')
option(`CONFIG_FOLD', `n', `n')
option(`CONFIG_HEAD', `y', `n')
option(`CONFIG_FEATURE_FANCY_HEAD', `n', `n')
option(`CONFIG_HOSTID', `n', `n')
option(`CONFIG_ID', `y', `n')
option(`CONFIG_INSTALL', `n', `n')
option(`CONFIG_FEATURE_INSTALL_LONG_OPTIONS', `n', `n')
option(`CONFIG_LENGTH', `n', `n')
option(`CONFIG_LN', `y', `y')
option(`CONFIG_LOGNAME', `n', `n')
option(`CONFIG_LS', `y', `y')
option(`CONFIG_FEATURE_LS_FILETYPES', `y', `n')
option(`CONFIG_FEATURE_LS_FOLLOWLINKS', `y', `n')
option(`CONFIG_FEATURE_LS_RECURSIVE', `n', `y')
option(`CONFIG_FEATURE_LS_SORTFILES', `y', `y')
option(`CONFIG_FEATURE_LS_TIMESTAMPS', `y', `y')
option(`CONFIG_FEATURE_LS_USERNAME', `y', `y')
option(`CONFIG_FEATURE_LS_COLOR', `y', `y')
option(`CONFIG_FEATURE_LS_COLOR_IS_DEFAULT', `y', `y')
option(`CONFIG_MD5SUM', `n', `n')
option(`CONFIG_MKDIR', `y', `y')
option(`CONFIG_FEATURE_MKDIR_LONG_OPTIONS', `n', `n')
option(`CONFIG_MKFIFO', `n', `n')
option(`CONFIG_MKNOD', `y', `n')
option(`CONFIG_MV', `y', `y')
option(`CONFIG_FEATURE_MV_LONG_OPTIONS', `n', `n')
option(`CONFIG_NICE', `y', `y')
option(`CONFIG_NOHUP', `n', `n')
option(`CONFIG_OD', `n', `n')
option(`CONFIG_PRINTENV', `n', `n')
option(`CONFIG_PRINTF', `n', `n')
option(`CONFIG_PWD', `y', `n')
option(`CONFIG_REALPATH', `n', `n')
option(`CONFIG_RM', `y', `y')
option(`CONFIG_RMDIR', `y', `y')
option(`CONFIG_SEQ', `n', `n')
option(`CONFIG_SHA1SUM', `n', `n')
option(`CONFIG_SLEEP', `y', `y')
option(`CONFIG_FEATURE_FANCY_SLEEP', `n', `n')
option(`CONFIG_SORT', `y', `y')
option(`CONFIG_FEATURE_SORT_BIG', `n', `n')
option(`CONFIG_SPLIT', `n', `n')
option(`CONFIG_FEATURE_SPLIT_FANCY', `n', `n')
option(`CONFIG_STAT', `n', `n')
option(`CONFIG_FEATURE_STAT_FORMAT', `n', `n')
option(`CONFIG_STTY', `n', `n')
option(`CONFIG_SUM', `n', `n')
option(`CONFIG_SYNC', `n', `y')
option(`CONFIG_TAIL', `y', `y')
option(`CONFIG_FEATURE_FANCY_TAIL', `y', `y')
option(`CONFIG_TEE', `n', `n')
option(`CONFIG_FEATURE_TEE_USE_BLOCK_IO', `n', `n')
option(`CONFIG_TEST', `y', `y')
option(`CONFIG_FEATURE_TEST_64', `n', `n')
option(`CONFIG_TOUCH', `y', `y')
option(`CONFIG_TR', `n', `n')
option(`CONFIG_FEATURE_TR_CLASSES', `n', `n')
option(`CONFIG_FEATURE_TR_EQUIV', `n', `n')
option(`CONFIG_TRUE', `y', `y')
option(`CONFIG_TTY', `y', `n')
option(`CONFIG_UNAME', `y', `y')
option(`CONFIG_UNEXPAND', `n', `n')
option(`CONFIG_UNIQ', `y', `n')
option(`CONFIG_USLEEP', `n', `n')
option(`CONFIG_UUDECODE', `n', `n')
option(`CONFIG_UUENCODE', `n', `n')
option(`CONFIG_WATCH', `n', `n')
option(`CONFIG_WC', `n', `n')
option(`CONFIG_FEATURE_WC_LARGE', `n', `n')
option(`CONFIG_WHO', `n', `n')
option(`CONFIG_WHOAMI', `y', `n')
option(`CONFIG_YES', `y', `y')

#
# Common options for cp and mv
#
option(`CONFIG_FEATURE_PRESERVE_HARDLINKS', `n', `n')

#
# Common options for ls, more and telnet
#
option(`CONFIG_FEATURE_AUTOWIDTH', `y', `y')

#
# Common options for df, du, ls
#
option(`CONFIG_FEATURE_HUMAN_READABLE', `y', `y')
option(`CONFIG_FEATURE_MD5_SHA1_SUM_CHECK', `n', `n')

#
# Console Utilities
#
option(`CONFIG_CHVT', `n', `n')
option(`CONFIG_CLEAR', `y', `y')
option(`CONFIG_DEALLOCVT', `n', `n')
option(`CONFIG_DUMPKMAP', `n', `n')
option(`CONFIG_LOADFONT', `n', `n')
option(`CONFIG_LOADKMAP', `n', `y')
option(`CONFIG_OPENVT', `n', `n')
option(`CONFIG_RESET', `y', `n')
option(`CONFIG_RESIZE', `n', `n')
option(`CONFIG_FEATURE_RESIZE_PRINT', `n', `n')
option(`CONFIG_SETCONSOLE', `n', `y')
option(`CONFIG_FEATURE_SETCONSOLE_LONG_OPTIONS', `n', `y')
option(`CONFIG_SETKEYCODES', `n', `n')
option(`CONFIG_SETLOGCONS', `n', `n')

#
# Debian Utilities
#
option(`CONFIG_MKTEMP', `n', `n')
option(`CONFIG_PIPE_PROGRESS', `n', `n')
option(`CONFIG_READLINK', `n', `n')
option(`CONFIG_FEATURE_READLINK_FOLLOW', `n', `n')
option(`CONFIG_RUN_PARTS', `y', `n')
option(`CONFIG_FEATURE_RUN_PARTS_LONG_OPTIONS', `n', `n')
option(`CONFIG_FEATURE_RUN_PARTS_FANCY', `n', `n')
option(`CONFIG_START_STOP_DAEMON', `n', `n')
option(`CONFIG_FEATURE_START_STOP_DAEMON_FANCY', `n', `n')
option(`CONFIG_FEATURE_START_STOP_DAEMON_LONG_OPTIONS', `n', `n')
option(`CONFIG_WHICH', `n', `n')

#
# Editors
#
option(`CONFIG_AWK', `n', `y')
option(`CONFIG_FEATURE_AWK_MATH', `n', `n')
option(`CONFIG_ED', `n', `n')
option(`CONFIG_PATCH', `n', `n')
option(`CONFIG_SED', `y', `y')
option(`CONFIG_VI', `y', `y')
CONFIG_FEATURE_VI_MAX_LEN=1024
option(`CONFIG_FEATURE_VI_COLON', `y', `y')
option(`CONFIG_FEATURE_VI_YANKMARK', `y', `y')
option(`CONFIG_FEATURE_VI_SEARCH', `y', `y')
option(`CONFIG_FEATURE_VI_USE_SIGNALS', `y', `y')
option(`CONFIG_FEATURE_VI_DOT_CMD', `y', `y')
option(`CONFIG_FEATURE_VI_READONLY', `y', `y')
option(`CONFIG_FEATURE_VI_SETOPTS', `y', `y')
option(`CONFIG_FEATURE_VI_SET', `y', `y')
option(`CONFIG_FEATURE_VI_WIN_RESIZE', `y', `y')
option(`CONFIG_FEATURE_VI_OPTIMIZE_CURSOR', `y', `y')
option(`CONFIG_FEATURE_ALLOW_EXEC', `n', `n')

#
# Finding Utilities
#
option(`CONFIG_FIND', `y', `y')
option(`CONFIG_FEATURE_FIND_PRINT0', `n', `n')
option(`CONFIG_FEATURE_FIND_MTIME', `n', `y')
option(`CONFIG_FEATURE_FIND_MMIN', `y', `y')
option(`CONFIG_FEATURE_FIND_PERM', `n', `n')
option(`CONFIG_FEATURE_FIND_TYPE', `y', `y')
option(`CONFIG_FEATURE_FIND_XDEV', `n', `n')
option(`CONFIG_FEATURE_FIND_MAXDEPTH', `y', `y')
option(`CONFIG_FEATURE_FIND_NEWER', `n', `n')
option(`CONFIG_FEATURE_FIND_INUM', `n', `n')
option(`CONFIG_FEATURE_FIND_EXEC', `n', `n')
option(`CONFIG_FEATURE_FIND_USER', `n', `n')
option(`CONFIG_FEATURE_FIND_GROUP', `n', `n')
option(`CONFIG_FEATURE_FIND_NOT', `n', `n')
option(`CONFIG_FEATURE_FIND_DEPTH', `n', `n')
option(`CONFIG_FEATURE_FIND_PAREN', `n', `n')
option(`CONFIG_FEATURE_FIND_SIZE', `n', `n')
option(`CONFIG_FEATURE_FIND_PRUNE', `n', `n')
option(`CONFIG_FEATURE_FIND_DELETE', `n', `n')
option(`CONFIG_FEATURE_FIND_PATH', `n', `n')
option(`CONFIG_FEATURE_FIND_REGEX', `n', `n')
option(`CONFIG_GREP', `y', `y')
option(`CONFIG_FEATURE_GREP_EGREP_ALIAS', `y', `n')
option(`CONFIG_FEATURE_GREP_FGREP_ALIAS', `n', `n')
option(`CONFIG_FEATURE_GREP_CONTEXT', `n', `n')
option(`CONFIG_XARGS', `y', `y')
option(`CONFIG_FEATURE_XARGS_SUPPORT_CONFIRMATION', `n', `n')
option(`CONFIG_FEATURE_XARGS_SUPPORT_QUOTES', `n', `n')
option(`CONFIG_FEATURE_XARGS_SUPPORT_TERMOPT', `n', `n')
option(`CONFIG_FEATURE_XARGS_SUPPORT_ZERO_TERM', `n', `n')

#
# Init Utilities
#
option(`CONFIG_INIT', `y', `y')
option(`CONFIG_DEBUG_INIT', `n', `n')
option(`CONFIG_FEATURE_USE_INITTAB', `y', `y')
option(`CONFIG_FEATURE_INIT_SCTTY', `n', `n')
option(`CONFIG_FEATURE_INIT_SYSLOG', `n', `n')
option(`CONFIG_FEATURE_EXTRA_QUIET', `n', `n')
option(`CONFIG_FEATURE_INIT_COREDUMPS', `n', `n')
option(`CONFIG_FEATURE_INITRD', `n', `n')
option(`CONFIG_HALT', `y', `y')
option(`CONFIG_MESG', `n', `n')

#
# Login/Password Management Utilities
#
option(`CONFIG_FEATURE_SHADOWPASSWDS', `y', `n')
option(`CONFIG_USE_BB_SHADOW', `n', `n')
option(`CONFIG_USE_BB_PWD_GRP', `n', `n')
option(`CONFIG_ADDGROUP', `n', `n')
option(`CONFIG_FEATURE_ADDUSER_TO_GROUP', `n', `n')
option(`CONFIG_DELGROUP', `n', `n')
option(`CONFIG_FEATURE_DEL_USER_FROM_GROUP', `n', `n')
option(`CONFIG_ADDUSER', `n', `n')
option(`CONFIG_DELUSER', `n', `n')
option(`CONFIG_GETTY', `n', `n')
option(`CONFIG_FEATURE_UTMP', `n', `n')
option(`CONFIG_FEATURE_WTMP', `n', `n')
option(`CONFIG_LOGIN', `y', `y')
option(`CONFIG_PAM', `n', `n')
option(`CONFIG_LOGIN_SCRIPTS', `y', `n')
option(`CONFIG_FEATURE_NOLOGIN', `n', `n')
option(`CONFIG_FEATURE_SECURETTY', `n', `n')
option(`CONFIG_PASSWD', `y', `y')
option(`CONFIG_FEATURE_PASSWD_WEAK_CHECK', `n', `n')
option(`CONFIG_CRYPTPW', `n', `n')
option(`CONFIG_CHPASSWD', `n', `n')
option(`CONFIG_SU', `n', `n')
option(`CONFIG_FEATURE_SU_SYSLOG', `n', `n')
option(`CONFIG_FEATURE_SU_CHECKS_SHELLS', `n', `n')
option(`CONFIG_SULOGIN', `n', `n')
option(`CONFIG_VLOCK', `n', `n')

#
# Linux Ext2 FS Progs
#
ifdef(`extfs',
`option(`CONFIG_CHATTR', `y', `y')
option(`CONFIG_FSCK', `y', `y')
option(`CONFIG_LSATTR', `y', `y')',
`option(`CONFIG_CHATTR', `n', `n')
option(`CONFIG_FSCK', `n', `n')
option(`CONFIG_LSATTR', `n', `n')'
)

#
# Linux Module Utilities
#
option(`CONFIG_INSMOD', `n', `y')
option(`CONFIG_FEATURE_INSMOD_VERSION_CHECKING', `n', `y')
option(`CONFIG_FEATURE_INSMOD_KSYMOOPS_SYMBOLS', `n', `n')
option(`CONFIG_FEATURE_INSMOD_LOADINKMEM', `n', `n')
option(`CONFIG_FEATURE_INSMOD_LOAD_MAP', `n', `n')
option(`CONFIG_FEATURE_INSMOD_LOAD_MAP_FULL', `n', `n')
option(`CONFIG_RMMOD', `n', `y')
option(`CONFIG_LSMOD', `n', `y')
option(`CONFIG_FEATURE_LSMOD_PRETTY_2_6_OUTPUT', `n', `n')
ifdef(`kernel26',
`option(`CONFIG_MODPROBE', `y', `y')
option(`CONFIG_FEATURE_MODPROBE_MULTIPLE_OPTIONS', `y', `y')',
`option(`CONFIG_MODPROBE', `n', `n')
option(`CONFIG_FEATURE_MODPROBE_MULTIPLE_OPTIONS', `n', `n')'
)
option(`CONFIG_FEATURE_MODPROBE_FANCY_ALIAS', `n', `n')
option(`CONFIG_FEATURE_CHECK_TAINTED_MODULE', `n', `n')
ifdef(`kernel26',
`option(`CONFIG_FEATURE_2_4_MODULES', `y', `y')
option(`CONFIG_FEATURE_2_6_MODULES', `y', `y')',
`option(`CONFIG_FEATURE_2_4_MODULES', `y', `y')
option(`CONFIG_FEATURE_2_6_MODULES', `n', `n')'
)
option(`CONFIG_FEATURE_QUERY_MODULE_INTERFACE', `n', `y')

#
# Linux System Utilities
#
option(`CONFIG_DMESG', `y', `y')
option(`CONFIG_FEATURE_DMESG_PRETTY', `y', `y')
option(`CONFIG_FBSET', `n', `n')
option(`CONFIG_FEATURE_FBSET_FANCY', `n', `n')
option(`CONFIG_FEATURE_FBSET_READMODE', `n', `n')
option(`CONFIG_FDFLUSH', `n', `n')
option(`CONFIG_FDFORMAT', `n', `n')
ifdef(`ide',
`option(`CONFIG_FDISK', `y', `y')
option(`CONFIG_FDISK_SUPPORT_LARGE_DISKS', `y', `y')
option(`CONFIG_FEATURE_FDISK_WRITABLE', `y', `y')',
`option(`CONFIG_FDISK', `n', `n')
option(`CONFIG_FDISK_SUPPORT_LARGE_DISKS', `n', `n')
option(`CONFIG_FEATURE_FDISK_WRITABLE', `n', `n')'
)
option(`CONFIG_FEATURE_AIX_LABEL', `n', `n')
option(`CONFIG_FEATURE_SGI_LABEL', `n', `n')
option(`CONFIG_FEATURE_SUN_LABEL', `n', `n')
option(`CONFIG_FEATURE_OSF_LABEL', `n', `n')
option(`CONFIG_FEATURE_FDISK_ADVANCED', `n', `n')
option(`CONFIG_FREERAMDISK', `n', `n')
option(`CONFIG_FSCK_MINIX', `n', `n')
option(`CONFIG_MKFS_MINIX', `n', `n')
option(`CONFIG_FEATURE_MINIX2', `n', `n')
option(`CONFIG_GETOPT', `n', `n')
option(`CONFIG_HEXDUMP', `n', `n')
option(`CONFIG_HWCLOCK', `n', `n')
#option(`CONFIG_FEATURE_HWCLOCK_LONGOPTIONS', `n', `n')
option(`CONFIG_FEATURE_HWCLOCK_ADJTIME_FHS', `n', `n')
option(`CONFIG_IPCRM', `n', `n')
option(`CONFIG_IPCS', `n', `n')
option(`CONFIG_LOSETUP', `n', `n')
option(`CONFIG_MDEV', `n', `n')
option(`CONFIG_FEATURE_MDEV_CONF', `n', `n')
ifdef(`ide',
`option(`CONFIG_MKSWAP', `y', `y')
option(`CONFIG_FEATURE_MKSWAP_V0', `n', `n')',
`option(`CONFIG_MKSWAP', `n', `n')
option(`CONFIG_FEATURE_MKSWAP_V0', `n', `n')'
)
option(`CONFIG_MORE', `y', `y')
option(`CONFIG_FEATURE_USE_TERMIOS', `y', `y')
option(`CONFIG_MOUNT', `y', `y')
ifdef(`cifs',
`option(`CONFIG_FEATURE_MOUNT_CIFS', `y', `y')',
`option(`CONFIG_FEATURE_MOUNT_CIFS', `n', `n')'
)
option(`CONFIG_FEATURE_MOUNT_FLAGS', `y', `y')
option(`CONFIG_FEATURE_MOUNT_FSTAB', `y', `y')
ifdef(`nfs',
`option(`CONFIG_FEATURE_MOUNT_NFS', `y', `y')',
`option(`CONFIG_FEATURE_MOUNT_NFS', `y', `n')'
)
option(`CONFIG_PIVOT_ROOT', `n', `n')
option(`CONFIG_RDATE', `n', `y')
option(`CONFIG_READPROFILE', `n', `n')
option(`CONFIG_SETARCH', `n', `n')
ifdef(`ide',
`option(`CONFIG_SWAPONOFF', `y', `y')',
`option(`CONFIG_SWAPONOFF', `n', `n')'
)
option(`CONFIG_SWITCH_ROOT', `n', `n')
option(`CONFIG_UMOUNT', `y', `y')
option(`CONFIG_FEATURE_UMOUNT_ALL', `n', `n')

#
# Common options for mount/umount
#
option(`CONFIG_FEATURE_MOUNT_LOOP', `y', `y')
option(`CONFIG_FEATURE_MTAB_SUPPORT', `n', `n')

#
# Miscellaneous Utilities
#
option(`CONFIG_ADJTIMEX', `n', `n')
option(`CONFIG_BBCONFIG', `n', `n')
option(`CONFIG_CHRT', `n', `n')
option(`CONFIG_CROND', `n', `n')
option(`CONFIG_FEATURE_CROND_CALL_SENDMAIL', `n', `n')
option(`CONFIG_CRONTAB', `n', `n')
option(`CONFIG_DC', `n', `n')
option(`CONFIG_DEVFSD', `n', `n')
option(`CONFIG_FEATURE_DEVFS', `y', `y')
option(`CONFIG_DEVFSD_MODLOAD', `n', `n')
option(`CONFIG_DEVFSD_FG_NP', `n', `n')
option(`CONFIG_DEVFSD_VERBOSE', `n', `n')
option(`CONFIG_EJECT', `n', `n')
option(`CONFIG_LAST', `n', `n')
option(`CONFIG_LESS', `n', `n')
option(`CONFIG_FEATURE_LESS_BRACKETS', `n', `n')
option(`CONFIG_FEATURE_LESS_FLAGS', `n', `n')
option(`CONFIG_FEATURE_LESS_FLAGCS', `n', `n')
option(`CONFIG_FEATURE_LESS_MARKS', `n', `n')
option(`CONFIG_FEATURE_LESS_REGEXP', `n', `n')
ifdef(`ide',
`option(`CONFIG_HDPARM', `y', `y')
option(`CONFIG_FEATURE_HDPARM_GET_IDENTITY', `y', `y')',
`option(`CONFIG_HDPARM', `n', `n')
option(`CONFIG_FEATURE_HDPARM_GET_IDENTITY', `n', `n')'
)
option(`CONFIG_FEATURE_HDPARM_HDIO_SCAN_HWIF', `n', `n')
option(`CONFIG_FEATURE_HDPARM_HDIO_UNREGISTER_HWIF', `n', `n')
option(`CONFIG_FEATURE_HDPARM_HDIO_DRIVE_RESET', `n', `n')
option(`CONFIG_FEATURE_HDPARM_HDIO_TRISTATE_HWIF', `n', `n')
option(`CONFIG_FEATURE_HDPARM_HDIO_GETSET_DMA', `n', `n')
option(`CONFIG_MAKEDEVS', `n', `n')
option(`CONFIG_FEATURE_MAKEDEVS_LEAF', `n', `n')
option(`CONFIG_FEATURE_MAKEDEVS_TABLE', `n', `n')
option(`CONFIG_MOUNTPOINT', `n', `n')
option(`CONFIG_MT', `n', `n')
option(`CONFIG_NMETER', `n', `n')
option(`CONFIG_RAIDAUTORUN', `n', `n')
option(`CONFIG_READAHEAD', `n', `n')
option(`CONFIG_RUNLEVEL', `n', `n')
option(`CONFIG_RX', `n', `n')
option(`CONFIG_STRINGS', `n', `n')
option(`CONFIG_SETSID', `n', `n')
option(`CONFIG_TASKSET', `n', `n')
option(`CONFIG_TIME', `y', `y')
option(`CONFIG_TTYSIZE', `n', `n')
option(`CONFIG_BB_WATCHDOG', `n', `n')

#
# Networking Utilities
#
option(`CONFIG_FEATURE_IPV6', `y', `n')
option(`CONFIG_VERBOSE_RESOLUTION_ERRORS', `n', `n')
option(`CONFIG_ARP', `n', `n')
option(`CONFIG_ARPING', `n', `n')
option(`CONFIG_DNSD', `n', `n')
option(`CONFIG_ETHER_WAKE', `n', `n')
option(`CONFIG_FAKEIDENTD', `n', `n')
option(`CONFIG_FTPGET', `n', `n')
option(`CONFIG_FTPPUT', `n', `n')
option(`CONFIG_FEATURE_FTPGETPUT_LONG_OPTIONS', `n', `n')
option(`CONFIG_HOSTNAME', `y', `y')
option(`CONFIG_HTTPD', `n', `n')
#option(`CONFIG_FEATURE_HTTPD_USAGE_FROM_INETD_ONLY', `n', `n')
option(`CONFIG_FEATURE_HTTPD_BASIC_AUTH', `n', `n')
option(`CONFIG_FEATURE_HTTPD_AUTH_MD5', `n', `n')
option(`CONFIG_FEATURE_HTTPD_RELOAD_CONFIG_SIGHUP', `n', `n')
option(`CONFIG_FEATURE_HTTPD_SETUID', `n', `n')
option(`CONFIG_FEATURE_HTTPD_CONFIG_WITH_MIME_TYPES', `n', `n')
option(`CONFIG_FEATURE_HTTPD_CGI', `n', `n')
option(`CONFIG_FEATURE_HTTPD_CONFIG_WITH_SCRIPT_INTERPR', `n', `n')
option(`CONFIG_FEATURE_HTTPD_SET_REMOTE_PORT_TO_ENV', `n', `n')
option(`CONFIG_FEATURE_HTTPD_ENCODE_URL_STR', `n', `n')
option(`CONFIG_IFCONFIG', `n', `y')
option(`CONFIG_FEATURE_IFCONFIG_STATUS', `n', `y')
option(`CONFIG_FEATURE_IFCONFIG_SLIP', `n', `n')
option(`CONFIG_FEATURE_IFCONFIG_MEMSTART_IOADDR_IRQ', `n', `n')
option(`CONFIG_FEATURE_IFCONFIG_HW', `n', `y')
option(`CONFIG_FEATURE_IFCONFIG_BROADCAST_PLUS', `n', `y')
option(`CONFIG_IFUPDOWN', `y', `y')
CONFIG_IFUPDOWN_IFSTATE_PATH="/var/run/ifstate"
option(`CONFIG_FEATURE_IFUPDOWN_IP', `y', `n')
option(`CONFIG_FEATURE_IFUPDOWN_IFCONFIG_BUILTIN', `y', `y')
option(`CONFIG_FEATURE_IFUPDOWN_IP_BUILTIN', `n', `n')
option(`CONFIG_FEATURE_IFUPDOWN_IPV4', `y', `y')
option(`CONFIG_FEATURE_IFUPDOWN_IPV6', `y', `n')
option(`CONFIG_FEATURE_IFUPDOWN_MAPPING', `n', `n')
option(`CONFIG_FEATURE_IFUPDOWN_EXTERNAL_DHCP', `n', `n')
option(`CONFIG_INETD', `y', `y')
option(`CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_ECHO', `n', `n')
option(`CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_DISCARD', `n', `n')
option(`CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_TIME', `n', `n')
option(`CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_DAYTIME', `n', `n')
option(`CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_CHARGEN', `n', `n')
option(`CONFIG_FEATURE_INETD_RPC', `n', `n')
option(`CONFIG_IP', `y', `y')
option(`CONFIG_FEATURE_IP_ADDRESS', `y', `y')
option(`CONFIG_FEATURE_IP_LINK', `y', `y')
option(`CONFIG_FEATURE_IP_ROUTE', `y', `y')
option(`CONFIG_FEATURE_IP_TUNNEL', `y', `n')
option(`CONFIG_FEATURE_IP_RULE', `y', `n')
option(`CONFIG_FEATURE_IP_SHORT_FORMS', `n', `n')
option(`CONFIG_IPCALC', `n', `n')
option(`CONFIG_FEATURE_IPCALC_FANCY', `n', `n')
option(`CONFIG_IPADDR', `n', `n')
option(`CONFIG_IPLINK', `n', `n')
option(`CONFIG_IPROUTE', `n', `n')
option(`CONFIG_IPTUNNEL', `n', `n')
option(`CONFIG_NAMEIF', `n', `n')
option(`CONFIG_NC', `y', `y')
option(`CONFIG_NC_SERVER', `y', `y')
option(`CONFIG_NC_EXTRA', `y', `y')
#option(`CONFIG_NC_GAPING_SECURITY_HOLE', `n', `n')
option(`CONFIG_NETSTAT', `y', `y')
option(`CONFIG_FEATURE_NETSTAT_WIDE', `y', `y')
option(`CONFIG_NSLOOKUP', `n', `y')
option(`CONFIG_PING', `y', `y')
option(`CONFIG_PSCAN', `n', `n')
option(`CONFIG_FEATURE_FANCY_PING', `n', `y')
option(`CONFIG_PING6', `n', `n')
option(`CONFIG_ROUTE', `n', `y')
option(`CONFIG_SLATTACH', `n', `n')
option(`CONFIG_TELNET', `n', `y')
option(`CONFIG_FEATURE_TELNET_TTYPE', `n', `y')
option(`CONFIG_FEATURE_TELNET_AUTOLOGIN', `n', `n')
option(`CONFIG_TELNETD', `y', `y')
option(`CONFIG_FEATURE_TELNETD_STANDALONE', `n', `n')
#option(`CONFIG_FEATURE_TELNETD_INETD', `y', `y')
option(`CONFIG_TFTP', `n', `n')
option(`CONFIG_FEATURE_TFTP_GET', `n', `n')
option(`CONFIG_FEATURE_TFTP_PUT', `n', `n')
option(`CONFIG_FEATURE_TFTP_BLOCKSIZE', `n', `n')
#option(`CONFIG_FEATURE_TFTP_DEBUG', `n', `n')
option(`CONFIG_TRACEROUTE', `n', `n')
option(`CONFIG_APP_UDHCPD', `n', `n')
option(`CONFIG_APP_UDHCPC', `y', `y')
#option(`CONFIG_FEATURE_UDHCP_SYSLOG', `y', `n')
option(`CONFIG_FEATURE_UDHCP_DEBUG', `n', `n')
option(`CONFIG_FEATURE_RFC3397', `n', `n')
option(`CONFIG_VCONFIG', `n', `n')
option(`CONFIG_WGET', `y', `y')
option(`CONFIG_FEATURE_WGET_STATUSBAR', `y', `y')
option(`CONFIG_FEATURE_WGET_AUTHENTICATION', `n', `y')
option(`CONFIG_FEATURE_WGET_LONG_OPTIONS', `n', `y')
option(`CONFIG_FEATURE_TRACEROUTE_VERBOSE', `n', `n')
option(`CONFIG_FEATURE_TRACEROUTE_SOURCE_ROUTE', `n', `n')
option(`CONFIG_FEATURE_TRACEROUTE_USE_ICMP', `n', `y')
option(`CONFIG_ZCIP', `n', `n')

#
# Process Utilities
#
option(`CONFIG_FREE', `y', `y')
option(`CONFIG_FUSER', `n', `n')
option(`CONFIG_KILL', `y', `y')
option(`CONFIG_KILLALL', `y', `y')
option(`CONFIG_KILLALL5', `n', `n')
option(`CONFIG_PIDOF', `y', `y')
option(`CONFIG_FEATURE_PIDOF_SINGLE', `n', `n')
option(`CONFIG_FEATURE_PIDOF_OMIT', `n', `n')
option(`CONFIG_PS', `y', `y')
option(`CONFIG_FEATURE_PS_WIDE', `n', `n')
option(`CONFIG_RENICE', `y', `y')
option(`CONFIG_BB_SYSCTL', `n', `n')
option(`CONFIG_TOP', `y', `y')
option(`CONFIG_FEATURE_TOP_CPU_USAGE_PERCENTAGE', `n', `n')
option(`CONFIG_UPTIME', `y', `y')

#
# Shells
#
option(`CONFIG_FEATURE_SH_IS_ASH', `y', `y')
option(`CONFIG_FEATURE_SH_IS_HUSH', `n', `n')
option(`CONFIG_FEATURE_SH_IS_LASH', `n', `n')
option(`CONFIG_FEATURE_SH_IS_MSH', `n', `n')
option(`CONFIG_FEATURE_SH_IS_NONE', `n', `n')
option(`CONFIG_ASH', `y', `y')

#
# Ash Shell Options
#
option(`CONFIG_ASH_JOB_CONTROL', `y', `n')
option(`CONFIG_ASH_READ_NCHARS', `n', `n')
option(`CONFIG_ASH_READ_TIMEOUT', `n', `n')
option(`CONFIG_ASH_ALIAS', `y', `y')
option(`CONFIG_ASH_MATH_SUPPORT', `y', `n')
option(`CONFIG_ASH_MATH_SUPPORT_64', `n', `n')
option(`CONFIG_ASH_GETOPTS', `n', `n')
option(`CONFIG_ASH_BUILTIN_ECHO', `n', `n')
option(`CONFIG_ASH_BUILTIN_TEST', `n', `n')
option(`CONFIG_ASH_CMDCMD', `n', `n')
option(`CONFIG_ASH_MAIL', `y', `n')
option(`CONFIG_ASH_OPTIMIZE_FOR_SIZE', `y', `n')
option(`CONFIG_ASH_RANDOM_SUPPORT', `n', `n')
option(`CONFIG_ASH_EXPAND_PRMT', `n', `n')
option(`CONFIG_HUSH', `n', `n')
option(`CONFIG_HUSH_HELP', `n', `n')
option(`CONFIG_HUSH_INTERACTIVE', `n', `n')
option(`CONFIG_HUSH_JOB', `n', `n')
option(`CONFIG_HUSH_TICK', `n', `n')
option(`CONFIG_HUSH_IF', `n', `n')
option(`CONFIG_HUSH_LOOPS', `n', `n')
option(`CONFIG_LASH', `n', `n')
option(`CONFIG_MSH', `n', `n')

#
# Bourne Shell Options
#
option(`CONFIG_FEATURE_SH_EXTRA_QUIET', `n', `n')
option(`CONFIG_CTTYHACK', `n', `n')

#
# System Logging Utilities
#
option(`CONFIG_SYSLOGD', `y', `y')
option(`CONFIG_FEATURE_ROTATE_LOGFILE', `y', `y')
option(`CONFIG_FEATURE_REMOTE_LOG', `y', `y')
option(`CONFIG_FEATURE_IPC_SYSLOG', `n', `n')
CONFIG_FEATURE_IPC_SYSLOG_BUFFER_SIZE=0
option(`CONFIG_LOGREAD', `n', `n')
option(`CONFIG_FEATURE_LOGREAD_REDUCED_LOCKING', `n', `n')
option(`CONFIG_KLOGD', `y', `n')
option(`CONFIG_LOGGER', `n', `n')

#
# Runit Utilities
#
option(`CONFIG_RUNSV', `n', `n')
option(`CONFIG_RUNSVDIR', `n', `n')
option(`CONFIG_SV', `n', `n')
option(`CONFIG_SVLOGD', `n', `n')
option(`CONFIG_CHPST', `n', `n')
option(`CONFIG_SETUIDGID', `n', `n')
option(`CONFIG_ENVUIDGID', `n', `n')
option(`CONFIG_ENVDIR', `n', `n')
option(`CONFIG_SOFTLIMIT', `n', `n')
option(`CONFIG_CHCON', `n', `n')
option(`CONFIG_FEATURE_CHCON_LONG_OPTIONS', `n', `n')
option(`CONFIG_GETENFORCE', `n', `n')
option(`CONFIG_GETSEBOOL', `n', `n')
option(`CONFIG_LOAD_POLICY', `n', `n')
option(`CONFIG_MATCHPATHCON', `n', `n')
option(`CONFIG_RUNCON', `n', `n')
option(`CONFIG_FEATURE_RUNCON_LONG_OPTIONS', `n', `n')
option(`CONFIG_SELINUXENABLED', `n', `n')
option(`CONFIG_SETENFORCE', `n', `n')

#
# ipsvd utilities
#
# CONFIG_TCPSVD is not set
# CONFIG_UDPSVD is not set
