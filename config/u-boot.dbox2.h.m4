changecom(`/*', `*/')dnl
ifdef(`rootsize',,`define(`rootsize',`0x660000')')dnl

/*
 * (C) Copyright 2000, 2001, 2002
 * Wolfgang Denk, DENX Software Engineering, wd@denx.de.
 *
 * Copyright (C) 2002 Bastian Blank <waldi@tuxbox.org>
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

/*
 * board/config.h - configuration options, board specific
 */

#ifndef __CONFIG_H
#define __CONFIG_H

#define UBOOT_TYPE_CDK		1
#define UBOOT_TYPE_CDK_26	2
#define UBOOT_TYPE_YADD		3
#define UBOOT_TYPE_SQUASHFS	4
#define UBOOT_TYPE_JFFS2	5
#define UBOOT_TYPE_CRAMFS	6
#define UBOOT_TYPE_FLASHER	7
#define UBOOT_TYPE_IDE		8

#define UBOOT_TYPE ifelse(
    uboottype,`cdk',`UBOOT_TYPE_CDK',
    uboottype,`cdk26',`UBOOT_TYPE_CDK26',
    uboottype,`yadd',`UBOOT_TYPE_YADD',
    uboottype,`squashfs',`UBOOT_TYPE_SQUASHFS',
    uboottype,`jffs2',`UBOOT_TYPE_JFFS2',
    uboottype,`cramfs',`UBOOT_TYPE_CRAMFS',
    uboottype,`flasher',`UBOOT_TYPE_FLASHER',
    uboottype,`ide',`UBOOT_TYPE_IDE',
    )

#if (UBOOT_TYPE == UBOOT_TYPE_SQUASHFS)
#define ROOTFS_OPTION 	"rootfstype=squashfs"
#define VAR_DIR_INFO 	"1:"

#elif (UBOOT_TYPE == UBOOT_TYPE_CRAMFS)
#define ROOTFS_OPTION 	"rootfstype=cramfs"
#define VAR_DIR_INFO 	"1:"

#elif (UBOOT_TYPE == UBOOT_TYPE_JFFS2)
#define ROOTFS_OPTION 	"rw rootfstype=jffs2"
#define VAR_DIR_INFO 	"0:var/"

#elif (UBOOT_TYPE == UBOOT_TYPE_IDE)
#define ROOTFS_OPTION 	"rw"
#define VAR_DIR_INFO 	"/var/"

#else
#define ROOTFS_OPTION
#define VAR_DIR_INFO

#endif

/*
 * High Level Configuration Options
 * (easy to change)
 */

#define	CONFIG_MPC823		1	/* This is a MPC823 CPU		*/
#define	CONFIG_DBOX2		1	/* ...on a dbox2 device		*/
#define	CONFIG_SECONDSTAGE	1	/* ...with a second state loader*/

#define	CONFIG_LCD_BOARD	1	/* ...with LCD			*/
#define	CONFIG_DBOX2_FB		1	/* ...with FB			*/

#if (UBOOT_TYPE == UBOOT_TYPE_IDE)
#define	CONFIG_DBOX2_IDE	1	/* ...with IDE-Interface	*/
#define CONFIG_DBOX2_CPLD_IDE   1	/* ...with CPLD-IDE             */ 
#define CONFIG_EXTERN_IDE_CODE  1	/* that needs its own code      */ 
#define CONFIG_IDE_PREINIT      1	/* and must be initialized      */
#endif

#define	CONFIG_HARD_I2C		1	/* ...and I2C hardware support	*/
#define	CFG_I2C_SPEED		50000
#define	CFG_I2C_SLAVE		0xFE

#define	CONFIG_8xx_CONS_SMC1	1	/* Console is on SMC1		*/
#undef	CONFIG_8xx_CONS_SMC2
#undef	CONFIG_8xx_CONS_NONE

#if 0
#define CONFIG_BOOTDELAY	-1	/* autoboot disabled		*/
#else
#define CONFIG_BOOTDELAY	1	/* autoboot after 5 seconds	*/
#endif


#undef	CONFIG_BOOTARGS

#define CONFIG_DBOX2_ENV_READ	1

#if (UBOOT_TYPE == UBOOT_TYPE_SQUASHFS) || (UBOOT_TYPE == UBOOT_TYPE_JFFS2) || (UBOOT_TYPE == UBOOT_TYPE_CRAMFS)
#define	CONFIG_BOOTCOMMAND 							\
	"protect off 10020000 107fffff; " 					\
	"fsload; setenv bootargs root=/dev/mtdblock2 " ROOTFS_OPTION " "	\
	"console=$(console),$(baudrate) dbox_duplex=$(dbox_duplex); " 		\
	"bootm"

#define	CONFIG_DBOX2_ENV_READ_FS	VAR_DIR_INFO "tuxbox/boot/boot.conf"

#elif (UBOOT_TYPE == UBOOT_TYPE_CDK) || (UBOOT_TYPE == UBOOT_TYPE_CDK26)
#define	CONFIG_BOOTCOMMAND							\
	"dhcp; tftp \"$(bootfile)\"; "						\
	"protect off 10020000 107fffff; "					\
        "setenv bootargs root=/dev/nfs rw nfsroot=$(rootpath) "			\
	"ip=$(ipaddr):$(serverip):$(gatewayip):$(netmask):$(hostname)::off "	\
	"console=$(console),$(baudrate) dbox_duplex=$(dbox_duplex) "		\
	"ifelse(uboottype,`cdk26',`init=/bin/devinit'); "			\
	"bootm"

#define CONFIG_LZMA		1	/* kernel LZMA decompression	*/

/* You can read boot.conf via nfs OR tftp */
#define CONFIG_DBOX2_ENV_READ_NFS	"/var/tuxbox/boot/boot.conf"
//#define CONFIG_DBOX2_ENV_READ_TFTP	"boot.conf"

#elif (UBOOT_TYPE == UBOOT_TYPE_YADD)
#define	CONFIG_BOOTCOMMAND							\
	"setenv bootargs console=$(console),$(baudrate) root=/dev/nfs rw "	\
	"nfsroot=$(serverip):$(rootpath)/yaddroot/ "				\
	"ip=$(ipaddr):$(serverip):$(gatewayip):$(netmask):$(hostname)::off; "	\
	"tftp \"kernel-yadd\"; protect off 10020000 107fffff; "			\
	"bootm"

/* You can read boot.conf via nfs OR tftp */
#define CONFIG_DBOX2_ENV_READ_NFS	"/var/tuxbox/boot/boot.conf"
//#define CONFIG_DBOX2_ENV_READ_TFTP	"boot.conf"

#elif (UBOOT_TYPE == UBOOT_TYPE_IDE)
#define	CONFIG_BOOTCOMMAND 							\
	"setenv bootargs root=/dev/ide/host0/bus0/target0/lun0/part2 " 		\
	ROOTFS_OPTION " rootfstype=ext2 " 					\
	"console=$(console),$(baudrate) dbox_duplex=$(dbox_duplex) idebus=66; "	\
	"ext2load ide 0:2 200000 vmlinuz; " 					\
	"bootm 200000"

#define	CONFIG_DBOX2_ENV_READ_FS	VAR_DIR_INFO "tuxbox/boot/boot.conf"
#else
#error "Wrong/no UBOOT_TYPE given via m4"
#endif

#define	CONFIG_EXTRA_ENV_SETTINGS 						\
	"console=ifelse(uboottype,`cdk26',`ttyCPM0',`ttyS0')\0"

#define CONFIG_BAUDRATE		9600	/* console baudrate = 9.6kbps	*/
#undef	CFG_LOADS_BAUD_CHANGE		/* don't allow baudrate change	*/

#define	CONFIG_WATCHDOG		1	/* watchdog enabled		*/

#define CONFIG_BOOTP_SUBNETMASK
#define CONFIG_BOOTP_GATEWAY
#define CONFIG_BOOTP_HOSTNAME
#define CONFIG_BOOTP_BOOTPATH
#define CONFIG_BOOTP_VENDOREX

#define CONFIG_BOOTP_NO_AUTOMATIC_TFTP

#define CONFIG_CMD_AUTOSCRIPT	/* Autoscript Support		*/
#define CONFIG_CMD_BDI		/* bdinfo			*/
#define CONFIG_CMD_BOOTD	/* bootd			*/
#define CONFIG_CMD_CONSOLE	/* coninfo			*/
#define CONFIG_CMD_DHCP		/* DHCP Support			*/
#define CONFIG_CMD_ECHO		/* echo arguments		*/

#if (UBOOT_TYPE == UBOOT_TYPE_SQUASHFS) || (UBOOT_TYPE == UBOOT_TYPE_JFFS2)
#define CONFIG_CMD_ENV		/* saveenv			*/
#endif

#define CONFIG_CMD_FLASH	/* flinfo, erase, protect	*/
#define CONFIG_CMD_FS		/* Generic FS Support		*/

#if (UBOOT_TYPE == UBOOT_TYPE_IDE)
#define CONFIG_CMD_IDE		/* IDE support			*/
#define CONFIG_CMD_EXT2		/* EXT2 Support			*/
#endif

#define CONFIG_CMD_IMI		/* iminfo			*/
#define CONFIG_CMD_IMLS		/* List all found images	*/
#define CONFIG_CMD_ITESTL	/* Integer (and string) test	*/
#define CONFIG_CMD_LOADS	/* loads			*/
#define CONFIG_CMD_LOADB	/* loadb			*/
#define CONFIG_CMD_MEMORY	/* md, mm, nm, mw, cp, cmp,	*/
#define CONFIG_CMD_MISC		/* Misc functions like sleep etc*/
#define CONFIG_CMD_NET		/* bootp, tftpboot, rarpboot	*/
#define CONFIG_CMD_NFS		/* NFS support			*/
#define CONFIG_CMD_RUN		/* run command in env variable	*/
#define CONFIG_CMD_SAVEENV
#define CONFIG_CMD_XIMG		/* Load part of Multi Image	*/

#define CONFIG_FS_CRAMFS		1
#define CONFIG_FS_JFFS2			2
#define CONFIG_FS_SQUASHFS		3

//#define CONFIG_CMD_CRAMFS

#if (UBOOT_TYPE == UBOOT_TYPE_SQUASHFS) || (UBOOT_TYPE == UBOOT_TYPE_CRAMFS)
#define CONFIG_CMD_SQUASHFS
#define CONFIG_CMD_JFFS2
#define CONFIG_FS		( ifelse(uboottype,`cramfs',`CONFIG_FS_CRAMFS |', uboottype,`squashfs',`CONFIG_FS_SQUASHFS |') CONFIG_FS_JFFS2 )
#define	CFG_FS_PART0_TYPE	CONFIG_FS_`'translit(uboottype, `a-z', `A-Z')
#define	CFG_FS_PART0_OFFSET	0x10040000
#define	CFG_FS_PART0_SIZE	rootsize
#define	CFG_FS_PART1_TYPE	CONFIG_FS_JFFS2
#define	CFG_FS_PART1_OFFSET	0x`'eval(0x10040000 + rootsize,16)
#define	CFG_FS_PART1_SIZE	0x`'eval(0x7c0000 - rootsize,16)
ifelse(uboottype,`squashfs', ifdef(`lzma',`#define CONFIG_SQUASHFS_LZMA 1'))

#elif (UBOOT_TYPE == UBOOT_TYPE_JFFS2)
#define CONFIG_CMD_JFFS2
#define CONFIG_FS		(CONFIG_FS_JFFS2)
#define	CFG_FS_PART0_TYPE	CONFIG_FS_JFFS2
#define	CFG_FS_PART0_OFFSET	0x10040000
#define	CFG_FS_PART0_SIZE	0x7c0000
ifdef(`lzma',`#define CONFIG_LZMA		1	/* kernel LZMA decompression	*/')
#endif

#if (UBOOT_TYPE == UBOOT_TYPE_IDE)
/*
 * ATAPI Support (experimental)
 */
#define CONFIG_ATAPI
#define CFG_ATA_STRIDE		1
#define CONFIG_SYS_IDE_MAXBUS		1                       /* max. 1 IDE busses    */
#define CONFIG_SYS_IDE_MAXDEVICE	(CONFIG_SYS_IDE_MAXBUS*2)      /* max. 2 drives per IDE bus */

#define CONFIG_SYS_ATA_BASE_ADDR	0x02000000   		/* base address */
#define CONFIG_SYS_ATA_IDE0_OFFSET	0x000                   /* default ide0 offste */
#define CONFIG_SYS_ATA_DATA_OFFSET	0x10                    /* data reg offset    */
#define CONFIG_SYS_ATA_REG_OFFSET	0x10                    /* reg offset */
#define CONFIG_SYS_ATA_ALT_OFFSET	0x48                    /* alternate register offset */

#undef  CONFIG_IDE_PCMCIA                               /* no pcmcia interface required */
#undef  CONFIG_IDE_LED                                  /* no led for ide supported */

#define CONFIG_DOS_PARTITION
#define CONFIG_MAC_PARTITION
#define CONFIG_ISO_PARTITION
#endif

#define CONFIG_TUXBOX_NETWORK			1
ifelse(uboottype,`yadd',`#define CONFIG_TUXBOX_BOOTMANAGER 1')

#ifdef	CONFIG_LCD_BOARD
#define	CONFIG_DBOX2_LCD_INFO			1
#define	CONFIG_DBOX2_LCD_LOGO			1

#if (UBOOT_TYPE == UBOOT_TYPE_SQUASHFS) || (UBOOT_TYPE == UBOOT_TYPE_JFFS2) || (UBOOT_TYPE == UBOOT_TYPE_IDE)
#define	CONFIG_DBOX2_LCD_LOGO_FS 		VAR_DIR_INFO "tuxbox/boot/logo-lcd"
#else
/*#define	CONFIG_DBOX2_LCD_LOGO_TFTP		"logo-lcd"*/
#define	CONFIG_DBOX2_LCD_LOGO_NFS		"/var/tuxbox/boot/logo-lcd"
#endif

#define	CONFIG_DBOX2_LCD_LOGO_RESERVE		2
#undef	CONFIG_DBOX2_LCD_FONT8x16
#endif	/* CONFIG_LCD_BOARD */

#ifdef	CONFIG_DBOX2_FB
#define	CONFIG_DBOX2_FB_LOGO			1
#if (UBOOT_TYPE == UBOOT_TYPE_SQUASHFS) || (UBOOT_TYPE == UBOOT_TYPE_JFFS2) || (UBOOT_TYPE == UBOOT_TYPE_IDE)
#define	CONFIG_DBOX2_FB_LOGO_FS			VAR_DIR_INFO "tuxbox/boot/logo-fb"
#else
//#define	CONFIG_DBOX2_FB_LOGO_TFTP		"logo-fb"
#define	CONFIG_DBOX2_FB_LOGO_NFS		"/var/tuxbox/boot/logo-fb"
#endif
#endif	/* CONFIG_DBOX2_FB */

#define	CONFIG_AUTOBOOT_SELECT			1
#define	CONFIG_AUTOBOOT_SELECT_AUTOBOOT		1
#define	CONFIG_AUTOBOOT_SELECT_NUMBER		3
#define	CONFIG_AUTOBOOT_SELECT_1_TEXT		"Console on null"
#define	CONFIG_AUTOBOOT_SELECT_1_COMMAND	"setenv console null"
#define	CONFIG_AUTOBOOT_SELECT_2_TEXT		"Console on ifelse(uboottype,`cdk26',`ttyCPM0',`ttyS0')"
#define	CONFIG_AUTOBOOT_SELECT_2_COMMAND	"setenv console ifelse(uboottype,`cdk26',`ttyCPM0',`ttyS0')"
#define	CONFIG_AUTOBOOT_SELECT_3_TEXT		"Console on framebuffer"
#define	CONFIG_AUTOBOOT_SELECT_3_COMMAND	"setenv console tty"
#define	CONFIG_AUTOBOOT_SELECT_4_TEXT		""
#define	CONFIG_AUTOBOOT_SELECT_4_COMMAND	""
#define	CONFIG_AUTOBOOT_SELECT_5_TEXT		""
#define	CONFIG_AUTOBOOT_SELECT_5_COMMAND	""

#if defined(CONFIG_DBOX2_LCD_LOGO) || defined(CONFIG_DBOX2_FB_LOGO)
#define	CONFIG_LAST_STAGE_INIT
#endif
/* #define	CONFIG_MISC_INIT_R		removed because it breaks NIC MAC detection by kernel */

/*
 * Miscellaneous configurable options
 */
#define	CONFIG_SYS_LONGHELP			/* undef to save memory		*/
#define	CONFIG_SYS_PROMPT		"=> "	/* Monitor Command Prompt	*/

#ifdef	CONFIG_SYS_HUSH_PARSER
#define	CONFIG_SYS_PROMPT_HUSH_PS2	"> "
#endif

#if (CONFIG_CMD_KGDB)
#define	CONFIG_SYS_CBSIZE		1024	/* Console I/O Buffer Size	*/
#else
#define	CONFIG_SYS_CBSIZE		512	/* Console I/O Buffer Size	*/
#endif
#define	CONFIG_SYS_PBSIZE (CONFIG_SYS_CBSIZE+sizeof(CONFIG_SYS_PROMPT)+16) /* Print Buffer Size */
#define	CONFIG_SYS_MAXARGS		16	/* max number of command args	*/
#define CONFIG_SYS_BARGSIZE		CONFIG_SYS_CBSIZE	/* Boot Argument Buffer Size	*/

#define CONFIG_SYS_MEMTEST_START	0x0400000	/* memtest works on	*/
#define CONFIG_SYS_MEMTEST_END		0x1800000	/* 4 ... 24 MB in DRAM	*/

#define	CONFIG_SYS_LOAD_ADDR		0x200000	/* default load address	*/

#define	CONFIG_SYS_HZ			1000	/* decrementer freq: 1 ms ticks	*/

#define CONFIG_SYS_BAUDRATE_TABLE	{ 9600, 19200, 38400, 57600, 115200 }

/*
 * Low Level Configuration Settings
 * (address mappings, register initial values, etc.)
 * You should know what you are doing if you make changes here.
 */
/*-----------------------------------------------------------------------
 * Internal Memory Mapped Register
 */
#define CONFIG_SYS_IMMR		0xFF000000

/*-----------------------------------------------------------------------
 * Definitions for initial stack pointer and data area (in DPRAM)
 */
#define CONFIG_SYS_INIT_RAM_ADDR	CONFIG_SYS_IMMR
#define	CONFIG_SYS_INIT_RAM_END	0x3000	/* End of used area in DPRAM	*/
#define	CONFIG_SYS_GBL_DATA_SIZE	64  /* size in bytes reserved for initial data */
#define CONFIG_SYS_GBL_DATA_OFFSET	(CONFIG_SYS_INIT_RAM_END - CONFIG_SYS_GBL_DATA_SIZE)
#define	CONFIG_SYS_INIT_SP_OFFSET	CONFIG_SYS_GBL_DATA_OFFSET

/*-----------------------------------------------------------------------
 * Address accessed to reset the board - must not be mapped/assigned
 */
#define	CONFIG_SYS_RESET_ADDRESS	0xFFFFFFFF

/*-----------------------------------------------------------------------
 * Start addresses for the final memory configuration
 * (Set up by the startup code)
 * Please note that CONFIG_SYS_SDRAM_BASE _must_ start at 0
 */
#define	CONFIG_SYS_SDRAM_BASE		0x00000000
#define CONFIG_SYS_FLASH_BASE		0x10000000
#define	CONFIG_SYS_MONITOR_LEN		(256 << 10)	/* Reserve 256 kB for Monitor	*/
#define CONFIG_SYS_MONITOR_BASE	0x40000
#define	CONFIG_SYS_MALLOC_LEN		(128 << 10)	/* Reserve 128 kB for malloc()	*/

/*
 * For booting Linux, the board info and command line data
 * have to be in the first 8 MB of memory, since this is
 * the maximum mapped by the Linux kernel during initialization.
 */
#define	CONFIG_SYS_BOOTMAPSZ		(8 << 20)	/* Initial Memory map for Linux	*/

/*-----------------------------------------------------------------------
 * FLASH organization
 */
#define CONFIG_SYS_MAX_FLASH_BANKS	2	/* max number of memory banks		*/
#define CONFIG_SYS_MAX_FLASH_SECT	71	/* max number of sectors on one chip	*/

#define CONFIG_SYS_FLASH_ERASE_TOUT	120000	/* Timeout for Flash Erase (in ms)	*/
#define CONFIG_SYS_FLASH_WRITE_TOUT	500	/* Timeout for Flash Write (in ms)	*/

#define	CONFIG_SYS_FLASH_CFI		1	/* Flash is CFI conformant		*/
#define	CONFIG_SYS_FLASH_PROTECTION	1	/* need to lock/unlock sectors in hardware */
#define	CONFIG_SYS_FLASH_USE_BUFFER_WRITE 1	/* use buffered writes (20x faster)	*/

#if (UBOOT_TYPE == UBOOT_TYPE_SQUASHFS) || (UBOOT_TYPE == UBOOT_TYPE_JFFS2)
#define	CONFIG_ENV_IS_IN_FLASH     1
#define	CONFIG_ENV_OFFSET		0x8000	/*   Offset   of Environment Sector     */
#else
#define	CONFIG_ENV_IS_NOWHERE	1
#endif
#define	CONFIG_ENV_SIZE		0x4000	/* Total Size of Environment Sector	*/

/*-----------------------------------------------------------------------
 * Hardware Information Block
 */
#define	CONFIG_SYS_HWINFO_OFFSET	0x0001FFE0	/* offset of HW Info block */
#define	CONFIG_SYS_HWINFO_SIZE		0x00000020	/* size   of HW Info block */

/*-----------------------------------------------------------------------
 * Cache Configuration
 */
#define CONFIG_SYS_CACHELINE_SIZE	16	/* For all MPC8xx CPUs			*/
#if (CONFIG_CMD_KGDB)
#define CONFIG_SYS_CACHELINE_SHIFT	4	/* log base 2 of the above value	*/
#endif

/*-----------------------------------------------------------------------
 * SYPCR - System Protection Control				11-9
 * SYPCR can only be written once after reset!
 *-----------------------------------------------------------------------
 * Software & Bus Monitor Timer max, Bus Monitor enable, SW Watchdog freeze
 */
#if defined(CONFIG_WATCHDOG)
#define CONFIG_SYS_SYPCR	(SYPCR_SWTC | SYPCR_BMT | SYPCR_BME | SYPCR_SWF | \
			 SYPCR_SWE  | SYPCR_SWRI| SYPCR_SWP)
#else
#define CONFIG_SYS_SYPCR	(SYPCR_SWTC | SYPCR_BMT | SYPCR_BME | SYPCR_SWF | SYPCR_SWP)
#endif

/*-----------------------------------------------------------------------
 * SIUMCR - SIU Module Configuration				11-6
 *-----------------------------------------------------------------------
 * PCMCIA config., multi-function pin tri-state
 */
#define CONFIG_SYS_SIUMCR	(SIUMCR_DBGC00 | SIUMCR_DBPC00 | SIUMCR_MLRC01)

/*-----------------------------------------------------------------------
 * TBSCR - Time Base Status and Control				11-26
 *-----------------------------------------------------------------------
 * Clear Reference Interrupt Status, Timebase freezing enabled
 */
#define CONFIG_SYS_TBSCR	(TBSCR_REFA | TBSCR_REFB | TBSCR_TBF)

/*-----------------------------------------------------------------------
 * PISCR - Periodic Interrupt Status and Control		11-31
 *-----------------------------------------------------------------------
 * Clear Periodic Interrupt Status, Interrupt Timer freezing enabled
 */
#define CONFIG_SYS_PISCR	(PISCR_PS | PISCR_PITF)

/*-----------------------------------------------------------------------
 * PLPRCR - PLL, Low-Power, and Reset Control Register		15-30
 *-----------------------------------------------------------------------
 * Reset PLL lock status sticky bit, timer expired status bit and timer
 * interrupt status bit
 *-----------------------------------------------------------------------
 * experimental CPU overclocking support - USE AT YOUR OWN RISK !
 * tuxbox-forum.dreambox-fan.de/forum/viewtopic.php?p=349695#p349695
 */
ifdef(`cpuclock',
`#define CPU_FREQ cpuclock`'000000
#define PLPRCR_MF ((CPU_FREQ/32768)-1) << 20
#define CONFIG_SYS_PLPRCR	(PLPRCR_SPLSS | PLPRCR_TEXPS | PLPRCR_TMIST | PLPRCR_MF)',
`#define CONFIG_SYS_PLPRCR	(PLPRCR_SPLSS | PLPRCR_TEXPS | PLPRCR_TMIST)')

/*-----------------------------------------------------------------------
 * SCCR - System Clock and reset Control Register		15-27
 *-----------------------------------------------------------------------
 * Set clock output, timebase and RTC source and divider,
 * power management and some other internal clocks
 */
#define SCCR_MASK	SCCR_EBDF11
#define CONFIG_SYS_SCCR	(SCCR_TBS     | \
			 SCCR_COM00   | SCCR_DFSYNC00 | SCCR_DFBRG00  | \
			 SCCR_DFNL000 | SCCR_DFNH000  | SCCR_DFLCD000 | \
			 SCCR_DFALCD00)

/*-----------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------
 *
 */
/*#define	CONFIG_SYS_DER	0x2002000F*/
#define CONFIG_SYS_DER	0

/*
 * Init Memory Controller:
 *
 * BR0/1 and OR0/1 (FLASH)
 */

#define FLASH_BASE_PRELIM	0x10000000	/* FLASH bank #0	*/

/*
 * Internal Definitions
 *
 * Boot Flags
 */
#define	BOOTFLAG_COLD	0x01		/* Normal Power-On: Boot from FLASH	*/
#define BOOTFLAG_WARM	0x02		/* Software reboot			*/

/* values according to the manual */

#define	BCSR_ADDR			((uint) 0xff010000)
#define	BCSR0				((uint) (BCSR_ADDR + 0x00))
#define	BCSR1				((uint) (BCSR_ADDR + 0x04))
#define	BCSR2				((uint) (BCSR_ADDR + 0x08))
#define	BCSR3				((uint) (BCSR_ADDR + 0x0c))
#define	BCSR4				((uint) (BCSR_ADDR + 0x10))

/* FADS bitvalues by Helmut Buchsbaum
 * see MPC8xxADS User's Manual for a proper description
 * of the following structures
 */

#define	BCSR0_ERB			((uint)0x80000000)
#define	BCSR0_IP			((uint)0x40000000)
#define	BCSR0_BDIS			((uint)0x10000000)
#define	BCSR0_BPS_MASK			((uint)0x0C000000)
#define	BCSR0_ISB_MASK			((uint)0x01800000)
#define	BCSR0_DBGC_MASK			((uint)0x00600000)
#define	BCSR0_DBPC_MASK			((uint)0x00180000)
#define	BCSR0_EBDF_MASK			((uint)0x00060000)

#define	BCSR1_FLASH_EN			((uint)0x80000000)
#define	BCSR1_DRAM_EN			((uint)0x40000000)
#define	BCSR1_ETHEN			((uint)0x20000000)
#define	BCSR1_IRDEN			((uint)0x10000000)
#define	BCSR1_FLASH_CFG_EN		((uint)0x08000000)
#define	BCSR1_CNT_REG_EN_PROTECT	((uint)0x04000000)
#define	BCSR1_BCSR_EN			((uint)0x02000000)
#define	BCSR1_RS232EN_1			((uint)0x01000000)
#define	BCSR1_PCCEN			((uint)0x00800000)
#define	BCSR1_PCCVCC0			((uint)0x00400000)
#define	BCSR1_PCCVPP_MASK		((uint)0x00300000)
#define	BCSR1_DRAM_HALF_WORD		((uint)0x00080000)
#define	BCSR1_RS232EN_2			((uint)0x00040000)
#define	BCSR1_SDRAM_EN			((uint)0x00020000)
#define	BCSR1_PCCVCC1			((uint)0x00010000)

#define	BCSR2_FLASH_PD_MASK		((uint)0xF0000000)
#define	BCSR2_DRAM_PD_MASK		((uint)0x07800000)
#define	BCSR2_DRAM_PD_SHIFT		(23)
#define	BCSR2_EXTTOLI_MASK		((uint)0x00780000)
#define	BCSR2_DBREVNR_MASK		((uint)0x00030000)

#define	BCSR3_DBID_MASK			((ushort)0x3800)
#define	BCSR3_CNT_REG_EN_PROTECT	((ushort)0x0400)
#define	BCSR3_BREVNR0			((ushort)0x0080)
#define	BCSR3_FLASH_PD_MASK		((ushort)0x0070)
#define	BCSR3_BREVN1			((ushort)0x0008)
#define	BCSR3_BREVN2_MASK		((ushort)0x0003)
#define	BCSR4_ETHLOOP			((uint)0x80000000)
#define	BCSR4_TFPLDL			((uint)0x40000000)
#define	BCSR4_TPSQEL			((uint)0x20000000)
#define	BCSR4_SIGNAL_LAMP		((uint)0x10000000)
#define	BCSR4_USB_EN			((uint)0x08000000)
#define	BCSR4_USB_SPEED			((uint)0x04000000)
#define	BCSR4_VCCO			((uint)0x02000000)
#define	BCSR4_VIDEO_ON			((uint)0x00800000)
#define	BCSR4_VDO_EKT_CLK_EN		((uint)0x00400000)
#define	BCSR4_VIDEO_RST			((uint)0x00200000)
#define	BCSR4_MODEM_EN			((uint)0x00100000)
#define	BCSR4_DATA_VOICE		((uint)0x00080000)

#endif	/* __CONFIG_H */
