export ARCHS = armv7 armv7s arm64 arm64e
export TARGET = iphone:16.5:9.0
INSTALL_TARGET_PROCESSES = SpringBoard
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FLEXing
FLEX_ROOT = $(PWD)/libflex/FLEX

# Convert directories to compiler include flags.
dtoim = $(foreach d,$(1),-I$(d))

# Keep the project tweak sources explicit, then compile FLEX sources into the
# same dylib so packaging produces a single FLEXing.dylib.
FLEXING_SOURCES = Tweak.xm SpringBoard.xm
FLEX_SOURCES  = $(shell find $(FLEX_ROOT)/Classes -name '*.c')
FLEX_SOURCES += $(shell find $(FLEX_ROOT)/Classes -name '*.m')
FLEX_SOURCES += $(shell find $(FLEX_ROOT)/Classes -name '*.mm')

# Add all FLEX source folders to the header search path because FLEX imports
# headers from multiple nested feature directories.
FLEX_IMPORTS  = $(shell /bin/ls -d $(FLEX_ROOT)/Classes/)
FLEX_IMPORTS += $(shell /bin/ls -d $(FLEX_ROOT)/Classes/*/)
FLEX_IMPORTS += $(shell /bin/ls -d $(FLEX_ROOT)/Classes/*/*/)
FLEX_IMPORTS += $(shell /bin/ls -d $(FLEX_ROOT)/Classes/*/*/*/)
FLEX_IMPORTS += $(shell /bin/ls -d $(FLEX_ROOT)/Classes/*/*/*/*/)

$(TWEAK_NAME)_GENERATOR = internal
$(TWEAK_NAME)_FILES = $(FLEXING_SOURCES) $(FLEX_SOURCES)
$(TWEAK_NAME)_FRAMEWORKS += CoreGraphics UIKit ImageIO QuartzCore
$(TWEAK_NAME)_LIBRARIES += sqlite3 z
$(TWEAK_NAME)_CFLAGS += -fobjc-arc -w -Wno-unsupported-availability-guard $(call dtoim,$(FLEX_IMPORTS))
$(TWEAK_NAME)_CCFLAGS += -std=gnu++11

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete

# For printing variables from the makefile.
print-% : ; @echo $* = $($*)
