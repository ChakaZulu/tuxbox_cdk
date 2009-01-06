# These variables are only used for generating template files in
# $(serversupport). Therefore, if they are not right, just override
# them from the invoking command, or edit the
# generated files.  It is not really worthwhile to make them ./configure-able.

DBOX_IP = 192.168.1.5
DBOX_SUBNET = $(basename $(DBOX_IP)).0
DBOX_SUBNETMASK = 255.255.255.0
DBOX_MAC = 00:50:9c:xx:xx:x

