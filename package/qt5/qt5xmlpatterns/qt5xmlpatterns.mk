################################################################################
#
# qt5xmlpatterns
#
################################################################################

QT5XMLPATTERNS_VERSION = $(QT5_VERSION)
QT5XMLPATTERNS_SITE = $(QT5_SITE)
QT5XMLPATTERNS_SOURCE = qtxmlpatterns-opensource-src-$(QT5XMLPATTERNS_VERSION).tar.xz
QT5XMLPATTERNS_DEPENDENCIES = qt5base
QT5XMLPATTERNS_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_QT5BASE_LICENSE_APPROVED),y)
ifeq ($(BR2_PACKAGE_QT5_VERSION_LATEST),y)
QT5XMLPATTERNS_LICENSE = GPL-2.0+ or LGPLv3, GPL-3.0 with exception(tools), GFDLv1.3 (docs)
QT5XMLPATTERNS_LICENSE_FILES = LICENSE.GPL2 LICENSE.GPLv3 LICENSE.GPL3-EXCEPT LICENSE.LGPLv3 LICENSE.FDL
else
QT5XMLPATTERNS_LICENSE = GPL-3.0 or LGPLv2.1 with exception or LGPLv3, GFDLv1.3 (docs)
QT5XMLPATTERNS_LICENSE_FILES = LICENSE.GPLv3 LICENSE.LGPLv21 LGPL_EXCEPTION.txt LICENSE.LGPLv3 LICENSE.FDL
endif
ifeq ($(BR2_PACKAGE_QT5BASE_EXAMPLES),y)
QT5XMLPATTERNS_LICENSE := $(QT5XMLPATTERNS_LICENSE), BSD-3c (examples)
endif
else
QT5XMLPATTERNS_LICENSE = Commercial license
QT5XMLPATTERNS_REDISTRIBUTE = NO
endif

define QT5XMLPATTERNS_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/qmake)
endef

define QT5XMLPATTERNS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define QT5XMLPATTERNS_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install
	$(QT5_LA_PRL_FILES_FIXUP)
endef

ifeq ($(BR2_STATIC_LIBS),)
define QT5XMLPATTERNS_INSTALL_TARGET_LIBS
	cp -dpf $(STAGING_DIR)/usr/lib/libQt5XmlPatterns*.so.* $(TARGET_DIR)/usr/lib
endef
endif

ifeq ($(BR2_PACKAGE_QT5BASE_EXAMPLES),y)
define QT5XMLPATTERNS_INSTALL_TARGET_EXAMPLES
	cp -dpfr $(STAGING_DIR)/usr/lib/qt/examples/xmlpatterns $(TARGET_DIR)/usr/lib/qt/examples/
endef
endif

define QT5XMLPATTERNS_INSTALL_TARGET_CMDS
	$(QT5XMLPATTERNS_INSTALL_TARGET_LIBS)
	$(QT5XMLPATTERNS_INSTALL_TARGET_EXAMPLES)
endef

$(eval $(generic-package))
