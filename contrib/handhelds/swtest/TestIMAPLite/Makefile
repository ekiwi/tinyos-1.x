# When building consider using the following options:
#
#    LONG_ADDRESS=number           Set the bottom 2 bytes of the long MAC address
#    SSID=string                   Set the SSID of the access point
#    IP=x.x.x.x                    Set the IP address of the access point
#    HOST_IP=x.x.x.x   	           Uses wired operation and sets HOST_IP='x.x.x.x'
#    IMAP_SERVER=x.x.x.x
#    
# For example:
#
#    make LONG_ADDRESS=15 SSID="CRL" IP='16.11.5.30' telosb       ---> Builds Wireless
#    make HOST_IP='16.11.5.50' IP='16.11.5.51' telosb             ---> Builds Wired

COMPONENT=TestIMAPLite
USE_IP=True
SELECT_WIRED_OR_WIRELESS=True
USE_WEB=test.fun

include ../Makerules

###################################################
# We only verify IMAP if we're not
# running a 'make clean'
###################################################

ifneq ($(TARGETS:clean%=clean),clean)

ifdef IMAP
PFLAGS += -DIMAP_SERVER="$(shell echo $(IMAP) | sed -e 's/\./,/g')"
else
$(error You must specify an IMAP server.)
endif

endif # ($(TARGETS),clean)
