# Experimental, does (essentially) nothing unless $(updatehttpprefix) is
# nonempty.

# Create a file with URLs containing lists of possible image files for
# updating. 

$(flashprefix)/root/etc/update.urls:
	@rm -f $@
	@touch $@
	if [ ! -z $(updatehttpprefix) ] ; then \
		echo $(updatehttpprefix)cramfs.list 	>> $@; \
		echo $(updatehttpprefix)squashfs.list 	>> $@; \
		echo $(updatehttpprefix)img.list 	>> $@; \
	fi
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@
