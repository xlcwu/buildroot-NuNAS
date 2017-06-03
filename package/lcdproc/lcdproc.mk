################################################################################
#
# lcdproc
#
################################################################################

LCDPROC_VERSION = 0.5.7
LCDPROC_SITE = http://downloads.sourceforge.net/project/lcdproc/lcdproc/$(LCDPROC_VERSION)
LCDPROC_LICENSE = GPL-2.0+
LCDPROC_LICENSE_FILES = COPYING
LCDPROC_MAKE = $(MAKE1)

LCDPROC_CONF_OPTS = --enable-drivers=$(BR2_PACKAGE_LCDPROC_DRIVERS)

ifeq ($(BR2_PACKAGE_LCDPROC_MENUS),y)
LCDPROC_CONF_OPTS += --enable-lcdproc-menus
endif

LCDPROC_DEPENDENCIES = freetype ncurses zlib

$(eval $(autotools-package))
