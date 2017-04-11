include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SuperSliders
SuperSliders_FILES = Tweak.xm
SuperSliders_FRAMEWORKS = UIKit
SuperSliders_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
