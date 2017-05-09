################################################################################
#
# xfsprogs
#
################################################################################

XFSPROGS_VERSION = 4.5.0
XFSPROGS_VERSION = 4.7.0
XFSPROGS_VERSION = 4.8.0
XFSPROGS_VERSION = 4.11.0
XFSPROGS_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/fs/xfs/xfsprogs
XFSPROGS_SOURCE = xfsprogs-$(XFSPROGS_VERSION).tar.xz

XFSPROGS_DEPENDENCIES = util-linux

# The libdir variable in lib*.la is empty, so let's fix it. This is
# probably due to acl not using automake, and not doing fully the
# right thing with libtool.
define XFSPROGS_FIX_LIBTOOL_LA_LIBDIR
        $(SED) "s,libdir=.*,libdir='$(STAGING_DIR)/usr/lib'," \
                $(STAGING_DIR)/usr/lib/libhandle.la
        $(SED) "s,libdir=.*,libdir='$(STAGING_DIR)/usr/lib'," \
                $(STAGING_DIR)/usr/lib/libxcmd.la
        $(SED) "s,libdir=.*,libdir='$(STAGING_DIR)/usr/lib'," \
                $(STAGING_DIR)/usr/lib/libxfs.la
        $(SED) "s,libdir=.*,libdir='$(STAGING_DIR)/usr/lib'," \
                $(STAGING_DIR)/usr/lib/libxlog.la
endef

XFSPROGS_POST_INSTALL_STAGING_HOOKS += XFSPROGS_FIX_LIBTOOL_LA_LIBDIR

XFSPROGS_CONF_ENV = ac_cv_header_aio_h=yes ac_cv_lib_rt_lio_listio=yes
XFSPROGS_CONF_OPTS = \
	--enable-lib64=no \
	--enable-gettext=no \
	INSTALL_USER=root \
	INSTALL_GROUP=root \
	--enable-static

ifeq ($(BR2_STATIC_LIBS),y)
XFSPROGS_CONF_OPTS += --disable-shared --enable-static
else ifeq ($(BR2_SHARED_LIBS),y)
XFSPROGS_CONF_OPTS += --enable-shared --disable-static

define XFSPROGS_ENABLE_SHARED
	find $(@D) -name Makefile -exec \
		sed -i -r -e '/^LLDFLAGS [+]?= -static(-libtool-libs)?$$/d' {} +
endef
XFSPROGS_POST_CONFIGURE_HOOKS += XFSPROGS_ENABLE_SHARED
endif

# xfsprogs links some of its programs to libs from util-linux, which use
# i18n functions. For shared-only builds, that's automatically pulled in.
# Static builds need some help, though...
#
# No need to depend on gettext in this case: xfsprogs does not use it for
# itself; util-linux does need it and has it in its own dependencies.
#
# xfsprogs' buildsystem uses hand-made Makefiles, not automake, and they
# do not use the LIBS variable set by configure. So we use EXTRALIBS that
# is added by our patch.
#
# It is not needed to propagate the EXTRALIBS to the install step.
ifeq ($(BR2_STATIC_LIBS)$(BR2_SHARED_STATIC_LIBS)$(BR2_NEEDS_GETTEXT_IF_LOCALE),yy)
XFSPROGS_CONF_OPTS += LIBS=-lintl
XFSPROGS_MAKE_OPTS = EXTRALIBS=-lintl
endif

XFSPROGS_INSTALL_TARGET_OPTS = DIST_ROOT=$(TARGET_DIR) install
XFSPROGS_INSTALL_TARGET_OPTS += -j1
XFSPROGS_INSTALL_STAGING = YES
XFSPROGS_INSTALL_STAGING_OPTS += -j1 DIST_ROOT=$(STAGING_DIR) install install-dev libxfs-install-dev

$(eval $(autotools-package))
