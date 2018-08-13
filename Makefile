include theos/makefiles/common.mk

SUBPROJECTS += appstorenohistoryhook
SUBPROJECTS += appstorenohistorysettings

include $(THEOS_MAKE_PATH)/aggregate.mk

all::
	
