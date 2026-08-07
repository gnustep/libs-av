# Copyright (C) 2022-2026 Free Software Foundation, Inc.
#
# Author: Gregory John Casamento <greg.casamento@gmail.com>
#
# This file is part of GNUstep.
#
ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif
ifeq ($(GNUSTEP_MAKEFILES),)
 $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

VERSION = 0.1
PACKAGE_NAME = AVFoundation

SUBPROJECTS = \
	AVFoundation \

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble
