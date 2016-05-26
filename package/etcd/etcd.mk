################################################################################
#
# etcd
#
################################################################################
ETCD_VERSION = v2.3.4
ETCD_SITE = https://github.com/coreos/etcd/archive
ETCD_SOURCE = $(ETCD_VERSION).tar.gz

ETCD_LICENSE = Apache-2.0
ETCD_LICENSE_FILES = LICENSE

ETCD_DEPENDENCIES = host-go

ETCD_MAKE_ENV = \
	$(HOST_GO_TARGET_ENV) \
	GOBIN="$(@D)/bin" \
	GOPATH="$(@D)/gopath" \
	CGO_ENABLED=0

ETCD_REPO_PATH = github.com/coreos/etcd

ETCD_GLDFLAGS = \
	-X $(ETCD_REPO_PATH)/version.GitSHA=$(ETCD_VERSION) \
	-extldflags '-static'

define ETCD_CONFIGURE_CMDS
	# Put sources at prescribed GOPATH location.
	mkdir -p $(@D)/gopath/src/github.com/coreos
	ln -s $(@D) $(@D)/gopath/src/$(ETCD_REPO_PATH)
endef

define ETCD_BUILD_CMDS
	cd $(@D) && $(ETCD_MAKE_ENV) $(HOST_GO_ROOT)/bin/go \
		build -v -x -ldflags "$(FLANNEL_GLDFLAGS)" \
		-o $(@D)/bin/etcd $(ETCD_REPO_PATH)
	cd $(@D) && $(ETCD_MAKE_ENV) $(HOST_GO_ROOT)/bin/go \
		build -v -x -ldflags "$(FLANNEL_GLDFLAGS)" \
		-o $(@D)/bin/etcdctl $(ETCD_REPO_PATH)/etcdctl
endef

define ETCD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/etcd $(TARGET_DIR)/usr/bin/etcd2
	$(INSTALL) -D -m 0755 $(@D)/bin/etcdctl $(TARGET_DIR)/usr/bin/etcdctl
endef

define ETCD_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D package/etcd/etcd2_sysv.conf \
		$(TARGET_DIR)/etc/etcd2.conf
	$(INSTALL) -m 0755 -D package/etcd/S80etcd2 \
		$(TARGET_DIR)/etc/init.d/S80etcd2
endef

define ETCD_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/etcd/etcd2.service \
		$(TARGET_DIR)/usr/lib/systemd/system/etcd2.service

	$(INSTALL) -D -m 644 package/etcd/etcd2_tmpfiles.conf \
		$(TARGET_DIR)/usr/lib/tmpfiles.d/etcd2.config

	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants

	ln -sf /usr/lib/systemd/system/etcd2.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/etcd2.service
endef

$(eval $(generic-package))
