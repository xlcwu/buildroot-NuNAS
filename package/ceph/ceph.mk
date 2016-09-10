################################################################################
#
# ceph
#
################################################################################

#CEPH_VERSION = 9.0.0 ###0.94.1
#CEPH_VERSION = 0.94.1
CEPH_VERSION = 5feb806905811add7f936d64fddbefe13d1c1f09
CEPH_VERSION = 9764da52395923e0b32908d83a9f7304401fee43
CEPH_VERSION = 0.94.9
CEPH_VERSION = 10.2.2
CEPH_SOURCE = ceph-$(CEPH_VERSION).tar.gz
CEPH_SITE = http://ceph.com/download
#CEPH_VERSION = bd7989103911796eb5698cf208b0ccdc3370d707
#CEPH_VERSION = v0.94.1.2
#CEPH_SITE = $(call github,ceph,ceph,$(CEPH_VERSION))
#CEPH_SITE_METHOD = git
CEPH_LICENSE = LGPLv2.1+
CEPH_LICENSE_FILES = COPYING
CEPH_INSTALL_STAGING = YES
CEPH_AUTORECONF = YES
###CEPH_LIBTOOL_PATCH = YES

# we're patching configure.in, but package cannot autoreconf with our version of
# autotools, so we have to do it manually instead of setting CEPH_AUTORECONF = YES
define CEPH_RUN_AUTOGEN
#	cd $(@D) && PATH=$(BR_PATH) ./do_autogen.sh
	cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
                $(@D)/src/Makefile.in
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
		$(@D)/src/ceph-detect-init/Makefile.am
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
		$(@D)/src/ceph-disk/Makefile.am
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
		$(@D)/src/pybind/cephfs/Makefile.am
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
		$(@D)/src/pybind/rados/Makefile.am
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
		$(@D)/src/pybind/rbd/Makefile.am
	cd $(@D) && $(SED) 's,ldl,ldl -lldap,' \
		$(@D)/src/rgw/Makefile.am
endef

CEPH_PRE_CONFIGURE_HOOKS += CEPH_RUN_AUTOGEN
HOST_CEPH_PRE_CONFIGURE_HOOKS += CEPH_RUN_AUTOGEN

CEPH_DEPENDENCIES += host-automake host-autoconf host-libtool \
			python-setuptools host-python-setuptools host-python-cython host-python-pip \
			libnspr icu snappy leveldb util-linux systemd keyutils libnss \
			gperftools libatomic_ops xfsprogs btrfs-progs boost \
			libfcgi libcurl libedit expat glibmm libsigc
HOST_CEPH_DEPENDENCIES += host-automake host-autoconf host-libtool host-snappy

CEPH_INSTALL_TARGET_OPTS += -j1 DESTDIR=$(TARGET_DIR) install
CEPH_INSTALL_STAGING_OPTS += -j1 \
	DESTDIR=$(STAGING_DIR) install

#	prefix=$(STAGING_DIR)/usr \
	exec_prefix=$(STAGING_DIR)/usr \
	install install-lib

define CEPH_FIX_LIBTOOL_LA_LIBDIR
        $(SED) "s,libdir=.*,libdir='$(STAGING_DIR)/usr/lib'," \
                $(STAGING_DIR)/usr/lib/librados.la
	$(SED) "s,libdir=.*,libdir='$(STAGING_DIR)/usr/lib'," \
		$(STAGING_DIR)/usr/lib/librgw.la
endef

CEPH_POST_INSTALL_STAGING_HOOKS += CEPH_FIX_LIBTOOL_LA_LIBDIR

# We disable everything for now, because the dependency tree can become
# quite deep if we try to enable some features, and I have not tested that.
# We need at least one crypto lib, and the only one currently available in
# BR, that ceph can use, is libnss (in deps, above)
CEPH_CONF_OPTS =		\
	--with-mon		\
	--with-evenfd		\
	--with-cython		\
	--with-nss		\
	--with-ocf

ifeq ($(BR2_PACKAGE_LIBFUSE),y)
CEPH_DEPENDENCIES += libfuse
CEPH_CONF_OPTS += --with-fuse
else
CEPH_CONF_OPTS += --without-fuse
endif

ifeq ($(BR2_PACKAGE_LIBAIO),y)
CEPH_DEPENDENCIES += libaio
CEPH_CONF_OPTS += --with-libaio
else
CEPH_CONF_OPTS += --without-libaio
endif

###CEPH_CONF_OPTS += --without-tcmalloc
ifeq ($(BR2_PACKAGE_OPENLDAP),y)
CEPH_DEPENDENCIES += openldap
CEPH_CONF_OPTS += --with-radosgw --with-openldap --with-ldap
endif

ifeq ($(BR2_PACKAGE_CEPH_ALL),y)
CEPH_DEPENDENCIES += jemalloc
CEPH_CONF_OPTS += --with-jemalloc
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
