include theos/makefiles/common.mk

TWEAK_NAME = AppstoreNoHistory

AppstoreNoHistory_FILES = /mnt/d/codes/appstorenohistory/appstorenohistoryhook/AppstoreNoHistory.xm
AppstoreNoHistory_FRAMEWORKS = CydiaSubstrate
AppstoreNoHistory_LDFLAGS = -Wl,-segalign,4000

AppstoreNoHistory_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
