################################################################################
#
# kviator
#
################################################################################

KVIATOR_VERSION = v0.0.7
KVIATOR_SITE = https://github.com/AcalephStorage/kviator/archive
KVIATOR_SOURCE = $(KVIATOR_VERSION).tar.gz

KVIATOR_LICENSE = Apache-2.0
KVIATOR_LICENSE_FILES = LICENSE

KVIATOR_DEPENDENCIES = host-go docker-engine etcd

KVIATOR_MAKE_ENV = \
	$(HOST_GO_TARGET_ENV) \
	GOBIN="$(@D)/bin" \
	GOPATH="$(@D)/gopath" \
	CGO_ENABLED=0

define KVIATOR_CONFIGURE_CMDS
        # Put sources at prescribed GOPATH location.
	mkdir -p $(@D)/gopath/src
	ln -s $(DOCKER_ENGINE_SRCDIR)/vendor/src/github.com $(@D)/gopath/src/github.com
	ln -s $(DOCKER_ENGINE_SRCDIR)/vendor/src/golang.org $(@D)/gopath/src/golang.org
	mv $(@D)/gopath/src/github.com/coreos/etcd $(@D)/gopath/src/github.com/coreos/etcd.old
	ln -s $(ETCD_SRCDIR) $(@D)/gopath/src/github.com/coreos/etcd
endef

define KVIATOR_BUILD_CMDS
	cd $(@D) && $(KVIATOR_MAKE_ENV) $(HOST_GO_ROOT)/bin/go \
		build -v -x -o $(@D)/bin/kviator .
endef

define KVIATOR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/kviator $(TARGET_DIR)/usr/bin/kviator
endef

$(eval $(generic-package))
